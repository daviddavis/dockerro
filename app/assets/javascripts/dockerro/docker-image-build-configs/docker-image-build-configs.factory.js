/**
 * @ngdoc service
 * @name  Bastion.products.factory:ProductBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on products.
 */
angular.module('Dockerro.docker-image-build-configs').factory('DockerImageBuildConfig',
['BastionResource',
function (BastionResource) {
  return BastionResource('/dockerro/api/v2/docker_image_build_configs/:id/:action',
  {id: '@id' }, {
  })
}]
);

/**
 * @ngdoc service
 * @name  Bastion.products.factory:ProductBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on products.
 */
angular.module('Dockerro.docker-images').factory('DockerImageBuildConfigBulkAction',
    ['BastionResource',
        function (BastionResource) {
            return BastionResource('/dockerro/api/v2/docker_images/:action',
                {}, {
                    bulkBuild: {method: 'POST', params: {action: 'bulk_build'}}
                })
        }]
);