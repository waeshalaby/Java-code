// use shared Libs to avoid copy/past with each new service
@Library('sharedLibs')_
pipeline {
environment {
	OPENSHIFT_DEV_NAMESPACE = 'dev-automation'
    OPENSHIFT_PREPROD_NAMESPACE = 'preprod-automation'
    OPENSHIFT_Build_Name = 'sampleapp'
    OPENSHIFT_PREPROD_CLUSTER = 'neo-cluster'
  }

	 agent {
		 label 'builder-slave' 
	 }
 
stages {
    stage("GIT Clone"){
        steps{
            git branch: "${gitlabBranch}" , credentialsId: 'githubCred', url: 'https://github.com/waeshalaby/Java-code.git'
        }   
    }
        stage('Build/Analyze Code') 
        {
            when {
                    expression {gitlabBranch ==~ '(dev/).*' || gitlabBranch ==~ '(release/).*' || gitlabBranch == 'master'}
                }
              steps {
                        script {
                                withSonarQubeEnv('SonarQube') {
                                sh "mvn clean install"
                              }
                     }
          }
        }  
        stage('Quality Gate') 
        {
            when {
                    expression {gitlabBranch ==~ '(dev/).*'  || gitlabBranch ==~ '(release/).*' || gitlabBranch == 'master'}
                }
                 steps {
                        script {
                                         def response 
                                        maxRetry = 200
                                        for (i=0; i<maxRetry; i++){
                                        try {
                                            timeout(time: 10, unit: 'SECONDS') 
                                            {
                                                response = waitForQualityGate abortPipeline: true
                                            }
                                        }
                                        catch(Exception e) 
                                        {
                                                 if (i == maxRetry-1)
                                                  {
                                                     throw e
                                                  }
                                                 }
                                                 if (response && response.status == 'OK' ) 
                                                 {
                                                    break
                                                }
                                              if (response && response.status == 'ERROR') 
                                              {
                                                        break
                                                }


  
                            }
                      }     
          }


    
      }
       stage ('openshift Build Image on Dev namespace')
       {
            when {
                    expression {gitlabBranch ==~ '(dev/).*'}
                }
                    steps {
                    wrap([$class: 'BuildUser']) {
                    buildImageOnOCPCluster('${OPENSHIFT_DEV_NAMESPACE}', '${OPENSHIFT_Build_Name}', "'${BUILD_NUMBER}'", "'${BUILD_USER}'", "${gitlabBranch}")
                         }
                    }
       }
            stage ('openshift Build Image on testing namespace')
       {
            when {
                    expression { gitlabBranch ==~ '(release/).*' || gitlabBranch == 'master'}
                }
                    steps {
                    wrap([$class: 'BuildUser']) {
                    buildImageOnOCPCluster('${OPENSHIFT_PREPROD_NAMESPACE}', '${OPENSHIFT_Build_Name}', "'${BUILD_NUMBER}'", "'${BUILD_USER}'", "${gitlabBranch}")
                         }
                    }
       }
          stage ('openshift Deployment on Dev namespace')
       {
            when {
                    expression {gitlabBranch ==~ '(dev/).*'}
                }
                    steps {
                            openshiftDeployment('neo-cluster', "${OPENSHIFT_DEV_NAMESPACE}" , 'deploy/base', 'simple-app')
                         }
        }
           stage ('openshift Deployment on testing namespace')
       {
            when {
                    expression { gitlabBranch ==~ '(release/).*' || gitlabBranch == 'master'}
                }
                    steps {
                            openshiftDeployment('neo-cluster', "${OPENSHIFT_PREPROD_NAMESPACE}" , 'deploy/testing', 'simple-app')
                         }
        }
    }
}
