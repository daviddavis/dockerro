#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Dockerro
    module DockerImageBuildConfig
      class BuildOnPublish < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        def self.subscribe
          ::Actions::Katello::ContentView::Publish
        end

        def plan(content_view, _)
          # Select applicable build configs, eg templates with automatic flag set
          #build_configs = content_view.docker_image_build_configs.select(&:template?).select(&:automatic?)
          build_configs = content_view.docker_image_build_configs.select(&:template?)
          require 'pry'; binding.pry
          compute_resource = ::Dockerro::BuildResource.scoped.first.compute_resource

          plan_self :build_config_ids => build_configs.map(&:id),
                    :compute_resource_id => compute_resource.id,
                    :hostname => hostname unless build_configs.empty?
          # Get compute resource from build resource

          # Plan bulk actions for each group
          nil
        end

        def finalize
          build_configs = input[:build_config_ids].map { |id| ::Dockerro::DockerImageBuildConfig.find(id) }
          require 'pry'; binding.pry
          world.trigger(::Actions::BulkAction,
                        ::Actions::Dockerro::DockerImageBuildConfig::Build,
                        build_configs,
                        input[:compute_resource_id],
                        input[:hostname])
          true
        end

        def hostname
          @capsule ||= ::Katello::CapsuleContent.default_capsule.capsule
          @capsule.hostname
        end

      end
    end
  end
end