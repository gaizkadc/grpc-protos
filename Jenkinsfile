import org.nalej.SlackHelper
def slackHelper = new SlackHelper()
def packageName = "grpc-protos"
def packagePath = "${packageName}"
def modifiedDirs = ""
def modifiedList = []

pipeline {
    agent { node { label 'grpc-protos' } }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage("Variable initialization") {
            steps { stepVariableInitialization packagePath }
        }
        stage("Git setup") {
            steps { container("golang") { stepGitSetup() } }
        }
        stage("Detect modified protocol buffers") {
            steps {
                script {
                    latestCommit = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
                    lastMergeCommit = sh(returnStdout: true, script: """
                    MERGE_NUMBER=1
                    GITLASTCOMMIT=\$(git rev-parse HEAD)
                    GITLASTMERGECOMMIT=\$(git log --merges -n \$MERGE_NUMBER --pretty=format:"%H")
                    if [ "\$GITLASTCOMMIT" == "\$GITLASTMERGECOMMIT" ]; then
                        MERGE_NUMBER=\$(( \$MERGE_NUMBER + 1))
                    fi
                    FOUND_MERGE=0
                    while [ \$FOUND_MERGE -eq 0 ]; do
                        MERGELOG=\$(git log --merges -n \$MERGE_NUMBER --pretty=format:"%s" | awk -v nr="\$MERGE_NUMBER" '{if (NR==nr) print \$0}')
                        if [[ \$MERGELOG == *"Merge branch 'master' into"* ]]; then
                        MERGE_NUMBER=\$(( \$MERGE_NUMBER + 1))
                        else
                        GITLASTMERGECOMMIT=\$(git log --merges -n \$MERGE_NUMBER --pretty=format:"%H" | awk -v nr="\$MERGE_NUMBER" '{if (NR==nr) print \$0}')
                        FOUND_MERGE=1
                        fi
                    done
                    echo \$GITLASTMERGECOMMIT
                    """).trim()
                    // lastMergeCommit = "6493e67c151c1c115148f0c3d2192650e448a216"  // Test with a known commit that has changes
                    modifiedDirs = sh(returnStdout: true, script: "set +ex && git diff --name-only ${latestCommit} ${lastMergeCommit} | grep \"^.*\\/.*.proto\$\" | awk -F/ '{print \$1}'").trim()
                    modifiedList = modifiedDirs.split("\n")
                    echo "We are going to build the protocol buffers since commit ID: ${lastMergeCommit}"
                    echo "Detected directories to generate:\n${modifiedDirs}"
                    if (env.CHANGE_ID) {
                        def prHelper = new org.daisho.github.PullRequest()
                        prHelper.clearComments()
                        prHelper.sendProtosComment(modifiedList)
                    }
                }
            }
        }
        stage("Generate modified protocol buffers") {
            steps {
                container("protoc") {
                    script {
                        sh("set +ex && ln -s /go/src ${WORKSPACE}/src")
                        for (directory in modifiedList) {
                            sh(script: """
                            set +ex
                            if [ -f ${directory}/.protolangs ]; then
                                while read lang; do
                                    echo "Generating ${directory} protocol buffers for \$lang language"
                                    /usr/local/bin/entrypoint.sh -d ${directory} -i . -i /usr/local/include/google -o ${directory}/pb-\$lang -l \$lang --with-docs --with-gateway
                                done < ${directory}/.protolangs
                            fi
                            """)
                        }
                    }
                }
            }
        }
        stage("Publish protocol buffers") {
            // when { branch 'master' }
            steps {
                container("golang") {
                    script {
                        for (directory in modifiedList) {
                            if (fileExists("${directory}/.protolangs")) {
                                protolangs = readFile("${directory}/.protolangs")
                                langList = protolangs.split("\n")
                                for (lang in langList) {
                                    repoName = "grpc-${directory}-${lang}"
                                    git url: "git@github.com:nalej/${repoName}.git", credentialsId: "jarvis-git-ssh-user"
                                    sshagent(['jarvis-git-ssh-user']) {
                                        sh(script: """
                                        if [ ! -f VERSION ]; then
                                            echo "Creating initial version"
                                            echo "0.0.0" > VERSION
                                        fi
                                        CURRENT_VERSION_STRING=\$(cat VERSION)
                                        VERSION_VALUES=\$(`echo \$CURRENT_VERSION_STRING | tr '.' ' '`)
                                        V_MAJOR=\${VERSION_VALUES[0]}
                                        V_MINOR=\${VERSION_VALUES[1]}
                                        V_PATCH=\${VERSION_VALUES[2]}
                                        V_PATCH=\$((V_PATCH + 1))
                                        NEW_VERSION="\${V_MAJOR}.\${V_MINOR}.\${V_PATCH}"
                                        echo "New version will be \${NEW_VERSION}"
                                        echo \$NEW_VERSION > VERSION
                                        git add .
                                        git commit -m "Auto generated gRPC"
                                        git push origin HEAD
                                        git tag -a -m "Auto generated version \${NEW_VERSION}." "v\$NEW_VERSION"
                                        git push origin --tags
                                        """)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
