/* jshint strict:false */

const sass = require('node-sass')

module.exports = {
  options: {
    implementation: sass
  },

  "general": {
    files: {
      'dist/general/css/main.css': [
        'src/general/sass/main.scss'
      ]
    }
  },

  "heart-walk": {
    files: {
      'dist/heart-walk/css/main.css': [
        'src/heart-walk/sass/main.scss'
      ],
      'dist/heart-walk/css/participant.css': [
        'src/heart-walk/sass/participant-center/main.scss'
      ],
      'dist/heart-walk/css/pageEdit.css': [
        'src/heart-walk/sass/page-edit/main.scss'
      ]
    }
  },

  "nchw": {
    files: {
      'dist/nchw/css/main.css': [
        'src/nchw/sass/main.scss'
      ]
    }
  },

  "heartchase": {
    files: {
      'dist/heartchase/css/main.css': [
        'src/heartchase/sass/main.scss'
      ]
    }
  },

  "cyclenation": {
    files: {
      'dist/cyclenation/css/main.css': [
        'src/cyclenation/sass/main.scss'
      ]
    }
  },

  "heartwalk2020": {
    files: {
      'dist/heartwalk2020/css/main.css': [
        'src/heartwalk2020/sass/main.scss'
      ],
      'dist/heartwalk2020/css/registration.css': [
        'src/heartwalk2020/sass/registration.scss'
      ],
      'dist/heartwalk2020/css/donation.css': [
        'src/heartwalk2020/sass/donation.scss'
      ]
    }
  },

  "fieldday": {
    files: {
      'dist/fieldday/css/main.css': [
        'src/fieldday/sass/main.scss'
      ],
      'dist/fieldday/css/registration.css': [
        'src/fieldday/sass/registration.scss'
      ],
      'dist/fieldday/css/donation.css': [
        'src/fieldday/sass/donation.scss'
      ]
    }
  },

  "fieldday2023": {
    files: {
      'dist/fieldday2023/css/main.css': [
        'src/fieldday2023/sass/main.scss'
      ]
    }
  },

  "heartwalklawyers": {
    files: {
      'dist/heartwalklawyers/css/main.css': [
        'src/heartwalklawyers/sass/main.scss'
      ],
      'dist/heartwalklawyers/css/registration.css': [
        'src/heartwalklawyers/sass/registration.scss'
      ],
      'dist/heartwalklawyers/css/donation.css': [
        'src/heartwalklawyers/sass/donation.scss'
      ]
    }
  },

  "leaders-for-life": {
    files: {
      'dist/leaders-for-life/css/main.css': [
        'src/leaders-for-life/sass/main.scss'
      ],
      'dist/leaders-for-life/css/registration.css': [
        'src/leaders-for-life/sass/registration.scss'
      ],
      'dist/leaders-for-life/css/donation.css': [
        'src/leaders-for-life/sass/donation.scss'
      ]
    }
  },
  "social-stem": {
    files: {
      'dist/social-stem/css/main.css': [
        'src/social-stem/sass/main.scss'
      ],
      'dist/social-stem/css/registration.css': [
        'src/social-stem/sass/registration.scss'
      ],
      'dist/social-stem/css/donation.css': [
        'src/social-stem/sass/donation.scss'
      ]
    }
  },
  "women-of-impact": {
    files: {
      'dist/women-of-impact/css/main.css': [
        'src/women-of-impact/sass/main.scss'
      ],
      'dist/women-of-impact/css/registration.css': [
        'src/women-of-impact/sass/registration.scss'
      ],
      'dist/women-of-impact/css/donation.css': [
        'src/women-of-impact/sass/donation.scss'
      ]
    }
  },
  "teens-of-impact": {
    files: {
      'dist/teens-of-impact/css/main.css': [
        'src/teens-of-impact/sass/main.scss'
      ],
      'dist/teens-of-impact/css/registration.css': [
        'src/teens-of-impact/sass/registration.scss'
      ],
      'dist/teens-of-impact/css/donation.css': [
        'src/teens-of-impact/sass/donation.scss'
      ]
    }
  }
}
