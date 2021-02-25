/* jshint strict:false */

module.exports = {
  options: {
    noAdvanced: true
  },

  "general": {
    files: [
      {
        src: 'dist/general/css/main.css',
        dest: 'dist/general/css/main.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  },

  "heart-walk": {
    files: [
      {
        src: 'dist/heart-walk/css/main.css',
        dest: 'dist/heart-walk/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/heart-walk/css/participant.css',
        dest: 'dist/heart-walk/css/participant.'+'<%= timestamp %>'+'.min.css'
      },
      {
        src: 'dist/heart-walk/css/pageEdit.css',
        dest: 'dist/heart-walk/css/pageEdit.'+'<%= timestamp %>'+'.min.css'
      }
    ]
  },

  "ym-primary": {
    files: [
      {
        src: 'dist/ym-primary/css/main.css',
        dest: 'dist/ym-primary/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/ym-primary/css/participant.css',
        dest: 'dist/ym-primary/css/participant.'+'<%= timestamp %>'+'.min.css'
      }
    ]
  },

  "middle-school": {
    files: [
      {
        src: 'dist/middle-school/css/main.css',
        dest: 'dist/middle-school/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/middle-school/css/participant.css',
        dest: 'dist/middle-school/css/participant.'+'<%= timestamp %>'+'.min.css'
      }
    ]
  },

  "high-school": {
    files: [
      {
        src: 'dist/high-school/css/main.css',
        dest: 'dist/high-school/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/high-school/css/participant.css',
        dest: 'dist/high-school/css/participant.'+'<%= timestamp %>'+'.min.css'
      }
    ]
  },

  "district-heart": {
    files: [
      {
        src: 'dist/district-heart/css/main.css',
        dest: 'dist/district-heart/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/district-heart/css/participant.css',
        dest: 'dist/district-heart/css/participant.'+'<%= timestamp %>'+'.min.css'
      }
    ]
  },

  "nchw": {
    files: [
      {
        src: 'dist/nchw/css/main.css',
        dest: 'dist/nchw/css/main.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  },

  "heartchase": {
    files: [
      {
        src: 'dist/heartchase/css/main.css',
        dest: 'dist/heartchase/css/main.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  },

  "cyclenation": {
    files: [
      {
        src: 'dist/cyclenation/css/main.css',
        dest: 'dist/cyclenation/css/main.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  },

  "heartwalk2020": {
    files: [
      {
        src: 'dist/heartwalk2020/css/main.css',
        dest: 'dist/heartwalk2020/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/heartwalk2020/css/registration.css',
        dest: 'dist/heartwalk2020/css/registration.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/heartwalk2020/css/donation.css',
        dest: 'dist/heartwalk2020/css/donation.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  },

  "fieldday": {
    files: [
      {
        src: 'dist/fieldday/css/main.css',
        dest: 'dist/fieldday/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/fieldday/css/registration.css',
        dest: 'dist/fieldday/css/registration.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/fieldday/css/donation.css',
        dest: 'dist/fieldday/css/donation.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  },

  "heartwalklawyers": {
    files: [
      {
        src: 'dist/heartwalklawyers/css/main.css',
        dest: 'dist/heartwalklawyers/css/main.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/heartwalklawyers/css/registration.css',
        dest: 'dist/heartwalklawyers/css/registration.'+ '<%= timestamp %>' +'.min.css'
      },
      {
        src: 'dist/heartwalklawyers/css/donation.css',
        dest: 'dist/heartwalklawyers/css/donation.'+ '<%= timestamp %>' +'.min.css'
      }
    ]
  }
}
