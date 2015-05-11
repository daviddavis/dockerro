module Actions
  module Dockerro
    module Image
      class Create < Actions::EntryAction

        input_format do
          param :prior_id, Integer
        end

        def plan(build_config, base_image, compute_resource, hostname)
          plan_action(::Actions::Dockerro::DockerImageBuildConfig::CreateAndAttachActivationKey, build_config.activation_key) if build_config.activation_key.new_record?
          # create container
          build_uuid = UUIDTools::UUID.random_create.hexdigest
          build_config.build_uuid = build_uuid
          build_options         = build_config.build_container_options compute_resource
          environment_variables = build_config.generate_environment_variables compute_resource, hostname, base_image

          sequence do
            unless base_image.nil?
              pull_options = build_options.merge :repository_name => build_config.base_image_path(hostname, base_image),
                                                 :tag             => base_image.name
              pull_container = plan_action(::Actions::Dockerro::Container::Create, pull_options)
              plan_action(::Actions::Dockerro::Container::Destroy,
                          :container_id => pull_container.output[:id])
            end
            container = plan_action(::Actions::Dockerro::Container::Create, build_options, environment_variables)

            # run it and wait for it to finish
            plan_action(::Actions::Dockerro::Container::MonitorRun,
                        :container_id        => container.output[:id],
                        :compute_resource_id => compute_resource.id)
            concurrence do
              # save package list into pulp
              plan_action(::Actions::Dockerro::Image::SaveToPulp,
                          build_config.image_name,
                          build_config.repository,
                          compute_resource)

              # delete container
              plan_action(::Actions::Dockerro::Container::Destroy,
                          :container_id => container.output[:id])
            end

            built_image = plan_self(:build_options         => build_options,
                                    :environment_variables => environment_variables,
                                    :repository_id         => build_config.repository.id,
                                    :tag                   => build_config.tag,
                                    :prior_id              => build_config.base_image_id,
                                    :pull_container_id     => pull_container ? pull_container.id : nil)

            system = plan_action(::Actions::Dockerro::Image::AssociateWithContentHost,
                                 :image_id => built_image.output[:image_id],
                                 :activation_key_id => build_config.activation_key.id,
                                 :build_uuid => build_uuid,
                                 :content_view_version_id => build_config.content_view_version.id)
            # Next action needs object responding to methods .id and .uuid
            tmp_system = Struct.new(:id, :uuid).new(system.output[:system_id], system.output[:system_uuid])

            plan_action(::Actions::Dockerro::System::BindRepositories,
                        [tmp_system],
                        build_config.content_view_version.repos(build_config.environment))
          end
        end

        def run
          repository        = ::Katello::Repository.find(input[:repository_id])
          built_image       = repository.docker_tags.select { |docker_tag| docker_tag.name == input[:tag] }.first.docker_image
          unless input[:prior_id].nil?
            base_image        = ::Katello::DockerImage.find(input[:prior_id])
            built_image.base_image = base_image
            built_image.save!
          end
          output[:image_id] = built_image.id
        end

        def humanized_name
          _("Create Docker Image")
        end

      end
    end
  end
end
