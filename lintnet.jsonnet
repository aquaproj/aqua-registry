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
          path: 'github_archive/github.com/lintnet-modules/nllint/main.jsonnet@8cfc4eae68ec93f9b92d9048ce51b0d9646c976c:v0.1.0',
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
        'github_archive/github.com/lintnet-modules/ghalint/workflow/**/main.jsonnet@00571db321e413d45be457f39e48cd4237399bb7:v0.3.0',
      ],
    },
  ],
}
