pipeline {
  agent any

  environment {
    DISABLE_SPINNER = "TRUE"

    ACCUKNOX_ENDPOINT = "cspm.demo.accuknox.com"
    ACCUKNOX_LABEL = "AccuKnoxInfyPOC"
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
      environment {
        DISABLE_SPINNER = "TRUE"

        RESULTS = ""
        BRANCH = "all"
        EXCLUDE_PATHS = ""
        SOFT_FAIL = "true" 
      }
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

    stage('Run Container Scan') {
      environment {
        SOFT_FAIL = "true"
        IMAGE = "test"
        IMAGE_TAG = "latest"
        SEVERITY = "CRITICAL,HIGH,WARNING,MEDIUM,LOW,INFO"
      }
      steps {
        script {
          def softFailArg = (env.SOFT_FAIL == 'true') ? '--softfail' : ''

          echo "Building Docker image ${env.IMAGE}:${env.IMAGE_TAG}..."
          sh "docker build -t ${env.IMAGE}:${env.IMAGE_TAG} -f Dockerfile ."
          def cmd = "image ${env.IMAGE}:${env.IMAGE_TAG}"
          if (env.SEVERITY?.trim())   { cmd += " --severity ${env.SEVERITY}" }
          def fullCmd = "~/.local/bin/accuknox-aspm-scanner scan ${softFailArg} container --command \"${cmd}\" --container-mode"
          echo "Running: ${fullCmd}"
          sh fullCmd
        }
      }
    }

    stage('Run IaC Scan') {
      environment {
        SOFT_FAIL = "true"
        DIRECTORY = "."
        COMPACT = "true"
        QUIET = "true"
        FILE = ""
        FRAMEWORK = ""
      }
      steps {
        script {
          def softFailArg = (env.SOFT_FAIL == 'true') ? '--softfail' : ''
          def cmdArgs = ""
          if (env.FILE?.trim())       { cmdArgs += " --file ${env.FILE}" }
          if (env.DIRECTORY?.trim())  { cmdArgs += " --directory ${env.DIRECTORY}" }
          if (env.COMPACT == 'true')  { cmdArgs += " --compact" }
          if (env.QUIET == 'true')    { cmdArgs += " --quiet" }
          if (env.FRAMEWORK?.trim())  { cmdArgs += " --framework ${env.FRAMEWORK}" }
          def fullCmd = "~/.local/bin/accuknox-aspm-scanner scan ${softFailArg} iac --command \"${cmdArgs}\" --container-mode"
          echo "Running: ${fullCmd}"
          sh fullCmd
        }
      }
    }

    stage('Run SAST Scan') {
      environment {
        SOFT_FAIL = "true"
      }
      steps {
        script {
          def softFailArg = (env.SOFT_FAIL == 'true') ? '--softfail' : ''
          def command = "scan ."
          def fullCmd = "~/.local/bin/accuknox-aspm-scanner scan ${softFailArg} sast --command \"${command}\" --container-mode"

          echo "Running: ${fullCmd}"
          sh fullCmd
        }
      }
    }

    stage('Run DAST Scan') {
      environment {
        SOFT_FAIL = "true"
        TARGET_URL = "https://juice-shop.herokuapp.com/"
        DAST_SCAN_SCRIPT = "zap-baseline.py"
      }
      steps {
        script {
          def softFailArg = (env.SOFT_FAIL == 'true') ? '--softfail' : ''
          sh '''
            mkdir -p /tmp/scan-dir
            chmod 777 /tmp/scan-dir
            cd /tmp/scan-dir
          '''
          def args = "${env.DAST_SCAN_SCRIPT} -t ${env.TARGET_URL} -I"
          def fullCmd = "~/.local/bin/accuknox-aspm-scanner scan ${softFailArg} dast --command \"${args}\" --container-mode"
          echo "Running: ${fullCmd}"
          sh fullCmd
          sh "cd -"
        }
      }
    }
  } 
}