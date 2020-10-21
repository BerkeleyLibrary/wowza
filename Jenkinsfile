dockerComposePipeline(
  stack: [template: 'app'],
  commands: ['/opt/app/test/run_tests.py'],
  artifacts: [
    junit   : 'artifacts/unittest/**/*.xml'
  ]
)
