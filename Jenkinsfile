import org.nalej.SlackHelper
def slackHelper = new SlackHelper()
def packageName = "grpc-protos"
def packagePath = "${packageName}"
def protoList = []
def repoList = []

pipeline {
    agent { node { label 'protos-slave' } }
    options {
        checkoutToSubdirectory("${packagePath}")
    }

    stages {
        stage("Variable initialization") {
            steps {
                script {
                    dir("${packagePath}") {
                        env.authorName = sh(returnStdout: true, script: "set +ex && git log --pretty=format:'%aN' -n 1").trim()
                    }
                }
            }
        }
        stage("gRPC repository generation") {
            when { not { branch 'master' } }
            steps {
                dir("${packagePath}") {
                    script {
                        if (env.CHANGE_ID) {
                            slackSend channel: "#madridteam", message: "Probando si ${env.authorName} ha hecho los protos bien...", botUser: false
                        }
                        sh "CURRENT_BRANCH=master REPOPATH=\$(pwd) DRY_RUN=true make generate"
                    }
                }
            }
            post {
                success {
                    if (env.CHANGE_ID) {
                        slackSend channel: "#madridteam", message: "La prueba de protos de ${env.authorName} salió bien", botUser: false
                    }
                }
                failure {
                    if (env.CHANGE_ID) {
                        slackSend channel: "#madridteam", message: "Ha fallado al probar los protos de ${env.authorName}", botUser: false
                    }
                }
            }
        }
        stage("gRPC repository generation and publish") {
            when { branch 'master' } 
            steps {
                dir("${packagePath}") {
                    script {
                        slackSend channel: "#madridteam", message: "Generando protos", botUser: false
                        sh "CURRENT_BRANCH=master REPOPATH=\$(pwd) make generate"
                    }
                }
            }
            post {
                success {
                    slackSend channel: "#madridteam", message: "Protos generados OK", botUser: false
                }
                failure {
                    slackSend channel: "#madridteam", message: "Ha fallado la generación de protos", botUser: false
                }
            }
        }
    }
    post {
        always {
            dir("${packagePath}") {
                sh "sudo chown -R jenkins:jenkins *"
                deleteDir()
            }
        }
}
