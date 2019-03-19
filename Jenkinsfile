import org.nalej.SlackHelper
def slackHelper = new SlackHelper()
def packageName = "grpc-protos"
def packagePath = "${packageName}"
def modifiedDirs = ""

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
                    // lastMergeCommit = sh(returnStdout: true, script: """
                    // MERGE_NUMBER=1
                    // GITLASTCOMMIT=\$(git rev-parse HEAD)
                    // GITLASTMERGECOMMIT=\$(git log --merges -n \$MERGE_NUMBER --pretty=format:"%H")
                    // if [ "\$GITLASTCOMMIT" == "\$GITLASTMERGECOMMIT" ]; then
                    //     MERGE_NUMBER=\$(( \$MERGE_NUMBER + 1))
                    // fi
                    // FOUND_MERGE=0
                    // while [ \$FOUND_MERGE -eq 0 ]; do
                    //     MERGELOG=\$(git log --merges -n \$MERGE_NUMBER --pretty=format:"%s" | awk -v nr="\$MERGE_NUMBER" '{if (NR==nr) print \$0}')
                    //     if [[ \$MERGELOG == *"Merge branch 'master' into"* ]]; then
                    //     MERGE_NUMBER=\$(( \$MERGE_NUMBER + 1))
                    //     else
                    //     GITLASTMERGECOMMIT=\$(git log --merges -n \$MERGE_NUMBER --pretty=format:"%H" | awk -v nr="\$MERGE_NUMBER" '{if (NR==nr) print \$0}')
                    //     FOUND_MERGE=1
                    //     fi
                    // done
                    // echo \$GITLASTMERGECOMMIT
                    // """).trim()
                    lastMergeCommit = "7c3496fb797b2e6989d46a198008924a7c5b6b12"  // Test with a known commit that has changes
                    modifiedDirs = sh(returnStdout: true, script: "git diff --name-only ${latestCommit} ${lastMergeCommit} | grep \"^.*\\/.*.proto\$\" | awk -F/ '{print \$1}'").trim()
                    echo "We are going to build the protocol buffers since commit ID: ${lastMergeCommit}"
                    echo "Detected directories to generate:\n${modifiedDirs}"
                }
            }
        }
    }
}
