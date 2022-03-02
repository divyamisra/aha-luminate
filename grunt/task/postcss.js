/* jshint strict:false */

module.exports = {
  options: {
    processors: [
      require('autoprefixer')({
        overrideBrowserslist: [
          'last 2 versions',
          'ie >= 9',
          'Safari >= 9',
          'ios_saf >= 9'
        ]
      })
    ]
  },

  "general": {
    files: [
      {
        expand: true,
        cwd: 'dist/general/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/general/css/'
      }
    ]
  },

  "heart-walk": {
    files: [
      {
        expand: true,
        cwd: 'dist/heart-walk/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/heart-walk/css/'
      },
      {
        expand: true,
        cwd: 'dist/heart-walk/css/',
        src: [
          'participant.css'
        ],
        dest: 'dist/heart-walk/css/'
      },
      {
        expand: true,
        cwd: 'dist/heart-walk/css/',
        src: [
          'pageEdit.css'
        ],
        dest: 'dist/heart-walk/css/'
      }
    ]
  },

  "ym-primary": {
    files: [
      {
        expand: true,
        cwd: 'dist/ym-primary/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/ym-primary/css/'
      },
      {
        expand: true,
        cwd: 'dist/ym-primary/css/',
        src: [
          'participant.css'
        ],
        dest: 'dist/ym-primary/css/'
      }
    ]
  },

  "middle-school": {
    files: [
      {
        expand: true,
        cwd: 'dist/middle-school/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/middle-school/css/'
      },
      {
        expand: true,
        cwd: 'dist/middle-school/css/',
        src: [
          'participant.css'
        ],
        dest: 'dist/middle-school/css/'
      }
    ]
  },

  "high-school": {
    files: [
      {
        expand: true,
        cwd: 'dist/high-school/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/high-school/css/'
      },
      {
        expand: true,
        cwd: 'dist/high-school/css/',
        src: [
          'participant.css'
        ],
        dest: 'dist/high-school/css/'
      }
    ]
  },

  "district-heart": {
    files: [
      {
        expand: true,
        cwd: 'dist/district-heart/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/district-heart/css/'
      },
      {
        expand: true,
        cwd: 'dist/district-heart/css/',
        src: [
          'participant.css'
        ],
        dest: 'dist/district-heart/css/'
      }
    ]
  },

  "nchw": {
    files: [
      {
        expand: true,
        cwd: 'dist/nchw/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/nchw/css/'
      }
    ]
  },

  "heartchase": {
    files: [
      {
        expand: true,
        cwd: 'dist/heartchase/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/heartchase/css/'
      }
    ]
  },

  "cyclenation": {
    files: [
      {
        expand: true,
        cwd: 'dist/cyclenation/css/',
        src: [
          'main.css'
        ],
        dest: 'dist/cyclenation/css/'
      }
    ]
  },

  "heartwalk2020": {
    files: [
      {
        expand: true,
        cwd: 'dist/heartwalk2020/css/',
        src: [
          'main.css',
          'registration.css',
          'donation.css'
        ],
        dest: 'dist/heartwalk2020/css/'
      }
    ]
  },

  "fieldday": {
    files: [
      {
        expand: true,
        cwd: 'dist/fieldday/css/',
        src: [
          'main.css',
          'registration.css',
          'donation.css'
        ],
        dest: 'dist/fieldday/css/'
      }
    ]
  },

  "heartwalklawyers": {
    files: [
      {
        expand: true,
        cwd: 'dist/heartwalklawyers/css/',
        src: [
          'main.css',
          'registration.css',
          'donation.css'
        ],
        dest: 'dist/heartwalklawyers/css/'
      }
    ]
  }
}
