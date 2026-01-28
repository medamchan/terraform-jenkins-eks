pipeline{
    agent any
    environment{
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages{
        stage('Checkout SCM'){
            steps{
                script{
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/medamchan/terraform-jenkins-eks.git']])
                }
            }
        }
        stage('Terraform Initialization'){
            steps{
                script{
                    dir('EKS'){
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Terraform formatting'){
            steps{
                script{
                    dir('EKS'){
                        sh 'terraform fmt'
                    }
                }
            }
        }
        stage('Terraform Validate'){
            steps{
                script{
                    dir('EKS'){
                        sh 'terraform validate'
                    }
                }
            }
        }
        stage('Terraform Plan'){
            steps{
                script{
                    dir('EKS'){
                        sh 'terraform plan'
                    }
                }
            }
        }
        stage('Terraform Apply/Destroy'){
            steps{
                script{
                    dir('EKS'){
                        sh 'terraform $action -auto-approve'
                    }
                }
            }
        }
        stage("Deploying Nginx Application"){
            steps{
                script{
                    dir('EKS/ConfigurationFiles'){
                        sh 'aws eks update-kubeconfig --name my-app-eks-cluster'
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
                }
            }
        }
    }
}