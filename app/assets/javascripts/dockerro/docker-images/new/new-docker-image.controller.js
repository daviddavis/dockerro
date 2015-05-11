/**
 * @ngdoc object
 * @name  Dockerro.docker-images.controller:NewDockerImageController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires FormUtils
 * @requires DDockerImage
 * @requires DockerTag
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires Repository
 * @requires BastionResource
 *
 * @description
 *   Controls the creation of a Docker Image object.
 */
angular.module('Dockerro.docker-images').controller('NewDockerImageController',
    ['$scope', '$q', '$location', 'FormUtils', 'DDockerImage', 'DockerTag', 'Organization', 'CurrentOrganization', 'ContentView', 'Repository', 'BastionResource',
        function ($scope, $q, $location, FormUtils, DockerImage, DockerTag, Organization, CurrentOrganization, ContentView, Repository, BastionResource) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            $scope.baseImageSelector = {
                baseImagesLoaded: true,
                environments: Organization.readableEnvironments({id: CurrentOrganization})
            };
            $scope.environments = Organization.readableEnvironments({id: CurrentOrganization})
            $scope.dockerImage = $scope.dockerImage || new DockerImage();
            $scope.panel = { 'loading': true };
            $scope.form = { 'environment': undefined };
            $scope.contentViews = [];
            $scope.dockerRegistries = [];
            $scope.pulpRepositories = [];
            $scope.computeResources = [];
            $scope.baseImages = [];
            $scope.cvloaded = true;
            $scope.dockerImage.default_key = true;

            $q.all([fetchPulpRepositories().$promise, fetchComputeResources().$promise]).finally(function () {
                $scope.panel.loading = false;
            });

            $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

            function fetchPulpRepositories() {
                return Repository.queryUnpaged({'content_type': 'docker'}, function (repos) {
                    $scope.pulpRepositories = repos.results;
                });
            }

            function fetchComputeResources() {
                var ComputeResource = BastionResource('/api/v2/compute_resources/:id/:action',
                    {id: '@id', organizationId: CurrentOrganization}, {
                    });
                return ComputeResource.queryUnpaged({'search': 'docker', 'organization_id': CurrentOrganization }, function (resources) {
                    $scope.computeResources = resources.results.filter(function(x) { if(x.provider == 'Docker') return x;});
                });
            }

            $scope.$watch('dockerImage.environment', function (environment) {
                if (environment) {
                    $scope.cvloaded = false;
                    ContentView.queryUnpaged({ 'environment_id': environment.id }, function (response) {
                        $scope.contentViews = response.results;
                        $scope.cvloaded = true;
                    });
                } else {
                    $scope.contentViews = [];
                }
            });

            $scope.$watch('baseImageSelector.environment', function(environment) {
                $scope.baseImages = [];
                if(environment) {
                    $scope.baseImagesLoaded = false;
                    DockerTag.queryUnpaged({
                        'environment_id': environment.id
                    }, function (tags) {
                        $scope.baseImages = tags.results;
                        $scope.baseImagesLoaded = true;
                    })
                }
            });

            $scope.save = function (dockerImage) {
                if(dockerImage.tag === undefined) { dockerImage.tag = "latest"; }
                dockerImage.organization_id = CurrentOrganization;
                dockerImage.$save(success, error);
            };

            function success(response) {
                $scope.working = false;
                $scope.transitionTo('task', {taskId: response.id});
            }

            function error(response) {
                $scope.working = false;
                $scope.errorMessages.push(response.data.displayMessage);
            }

        }]
);
