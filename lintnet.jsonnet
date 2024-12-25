// A configuration file of lintnet.
// https://lintnet.github.io/
function(param) {
  targets: [
    {
      data_files: [
        '**/*',
      ],
      modules: [
        {
          path: 'github_archive/github.com/lintnet-modules/nllint/main.jsonnet@a36d23d28936a85df8cad6e831c16854e9e2caa6:v0.2.0',
          config: {
            trim_space: true,
          },
        },
      ],
    },
    {
      data_files: [
        '.github/workflows/*.yml',
        '.github/workflows/*.yaml',
      ],
      modules: [
        'github_archive/github.com/lintnet-modules/ghalint/workflow/**/main.jsonnet@12aac7476916a42e9de8646ac75c98274cfe8521:v0.3.2',
      ],
    },
  ],
}
