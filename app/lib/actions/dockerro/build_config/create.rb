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
      class Create < Actions::EntryAction

        def plan(build_config)
          build_config.save!
          require 'pry'; binding.pry
          plan_self :build_config_id => build_config.id
        end

        def run
          output[:build_config_id] = input[:build_config_id]
        end

        def humanized_name
          _("Create Build Config")
        end

      end
    end
  end
end
