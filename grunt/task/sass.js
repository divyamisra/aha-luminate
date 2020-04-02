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
  
  "ym-primary": {
    files: {
      'dist/ym-primary/css/main.css': [
        'src/ym-primary/sass/main.scss'
      ], 
      'dist/ym-primary/css/participant.css': [
        'src/ym-primary/sass/participant.scss'
      ]
    }
  }, 
  
  "middle-school": {
    files: {
      'dist/middle-school/css/main.css': [
        'src/middle-school/sass/main.scss'
      ], 
      'dist/middle-school/css/participant.css': [
        'src/middle-school/sass/participant.scss'
      ]
    }
  }, 
  
  "high-school": {
    files: {
      'dist/high-school/css/main.css': [
        'src/high-school/sass/main.scss'
      ], 
      'dist/high-school/css/participant.css': [
        'src/high-school/sass/participant.scss'
      ]
    }
  }, 
  
  "district-heart": {
    files: {
      'dist/district-heart/css/main.css': [
        'src/district-heart/sass/main.scss'
      ], 
      'dist/district-heart/css/participant.css': [
        'src/district-heart/sass/participant.scss'
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
  }
}
