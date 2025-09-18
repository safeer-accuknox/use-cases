pipeline {
  agent any

  environment {
    RESULTS = ""
    BRANCH = "all"
    EXCLUDE_PATHS = ""
    SOFT_FAIL = "false" 

    ACCUKNOX_ENDPOINT = "cspm.demo.accuknox.com"
    ACCUKNOX_LABEL = "ROOTFS"
    ACCUKNOX_TOKEN = credentials('ACCUKNOX_TOKEN')
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
          python3 -m pip install --user \
            https://github.com/accuknox/aspm-scanner-cli/releases/download/v0.13.4/accuknox_aspm_scanner-0.13.4-py3-none-any.whl --break-system-packages
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

          def fullCmd = "~/.local/bin/accuknox-aspm-scanner scan ${softFailArg} secret --command \"${command}${args}\" --container-mode"
          echo "Running: ${fullCmd}"
          sh fullCmd
        }
      }
    }
  }

}
