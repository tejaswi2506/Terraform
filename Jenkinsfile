pipeline {
  agent { label 'maven-agent' }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  parameters {
    choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Environment under env/')
    string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS region')
    // string(name: 'TF_VAR_instance_type', defaultValue: '', description: 'Optional override (e.g., t3.micro)')
    // string(name: 'TF_VAR_key_name', defaultValue: '', description: 'Optional override (existing key pair name)')
    // string(name: 'TF_VAR_ssh_allowed_cidr', defaultValue: '', description: 'Optional override (x.x.x.x/32)')
    // string(name: 'TF_VAR_name_prefix', defaultValue: '', description: 'Optional override (resource prefix)')
  }

  environment {
    TF_IN_AUTOMATION     = "true"
    TF_INPUT             = "false"
    AWS_DEFAULT_REGION   = "${params.REGION}"
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Tool Check') {
      steps {
        sh '''
          set -e
          terraform -version
          aws --version
          git --version
        '''
      }
    }

    stage('Terraform fmt -check') {
      steps {
        sh 'terraform fmt -check -recursive'
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          set -e
          cd "env/${ENV}"
          terraform init -input=false
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        sh '''
          set -e
          cd "env/${ENV}"
          terraform validate
        '''
      }
    }

    stage('Terraform Plan (artifact)') {
      steps {
        sh '''
          set -e
          cd "env/${ENV}"
          rm -f tfplan tfplan.txt
          terraform plan -input=false -out=tfplan | tee tfplan.txt
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: "env/${ENV}/tfplan,env/${ENV}/tfplan.txt", fingerprint: true, onlyIfSuccessful: false
        }
      }
    }

    stage('Manual Approval') {
      when {
        anyOf {
          expression { params.ACTION == 'apply' }
          expression { params.ACTION == 'destroy' }
        }
      }
      steps {
        input message: "Approve Terraform ${params.ACTION} for ENV=${params.ENV} REGION=${params.REGION}?", ok: "Approve"
      }
    }

    stage('Apply / Destroy') {
      steps {
        sh '''
          set -e
          cd "env/${ENV}"

          if [ "${ACTION}" = "apply" ]; then
            terraform apply -input=false -auto-approve tfplan
          elif [ "${ACTION}" = "destroy" ]; then
            terraform destroy -input=false -auto-approve
          else
            echo "ACTION=plan selected. Skipping apply/destroy."
          fi
        '''
      }
    }
  }
}
