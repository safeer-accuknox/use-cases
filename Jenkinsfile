pipeline {
  agent any

  environment {
    RESULTS = ""
    BRANCH = "all"
    EXCLUDE_PATHS = ""
    SOFT_FAIL = "false" 
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install ASPM scanner') {
      steps {
        sh '''
          set -e
          pip install https://github.com/accuknox/aspm-scanner-cli/releases/download/v0.12.1/accuknox_aspm_scanner-0.12.1-py3-none-any.whl --break-system-packages
        '''
      }
    }

    stage('Run Secret Scan') {
      steps {
        script {
          def softFailArg = (env.SOFT_FAIL == 'true') ? '--softfail' : ''
          def command = 'git file://.'
          def args = ''
          if (env.RESULTS?.trim())       { args += " --results ${env.RESULTS}" }
          if (env.BRANCH?.trim())        { args += " --branch ${env.BRANCH}" }
          if (env.EXCLUDE_PATHS?.trim()) { args += " --exclude-paths '${env.EXCLUDE_PATHS}'" }

          def fullCmd = "accuknox-aspm-scanner scan ${softFailArg} secret --command \"${command}${args}\" --container-mode"
          echo "Running: ${fullCmd}"

          if (env.SOFT_FAIL == 'true') {
            def status = sh(script: fullCmd, returnStatus: true)
            if (status != 0) {
              currentBuild.result = 'UNSTABLE'
              echo "Scanner exited with ${status} (soft-fail enabled) — build marked UNSTABLE."
            }
          } else {
            sh fullCmd
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'results/**/*, scan_results/**/*', allowEmptyArchive: true
    }
  }
}
