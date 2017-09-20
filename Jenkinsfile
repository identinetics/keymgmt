pipeline {
    agent any

    stages {
        stage('Pre-Cleanup') {
            steps {
            sh './dscripts/manage.sh rm 2>&1 || true'
            sh './dscripts/manage.sh rmvol 2>&1 || true'
            }
        }
        stage('Build') {
            steps {
                sh '''
                echo 'Building..'
                ln -sf conf.sh.default conf.sh
                ./dscripts/build.sh
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                echo 'Testing GPG Card Signature - requires HW ..'
                ./dscripts/run.sh -I /tests/test_gpg_card_sig.sh
                '''
            }
        }
    }
    post {
        always {
            echo 'removing docker volumes and container '
            sh './dscripts/manage.sh rm 2>&1 || true'
            sh './dscripts/manage.sh rmvol 2>&1 || true'
        }
    }
}
