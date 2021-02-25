/* jshint strict:false */

module.exports = {
  "general": {
    files: [
      {
        src: [
          'dist/general/js/main.js'
        ],
        dest: 'dist/general/js/main.' + '<%= timestamp %>' + '.min.js'
      }
    ]
  },

  "heart-walk": {
    files: [
      {
        src: [
          'dist/heart-walk/js/main.js'
        ],
        dest: 'dist/heart-walk/js/main.' + '<%= timestamp %>' + '.min.js'
      },
      {
        src: [
          'dist/heart-walk/js/participant.js'
        ],
        dest: 'dist/heart-walk/js/participant.' + '<%= timestamp %>' + '.min.js'
      },
      {
        src: [
          'dist/heart-walk/js/pageEdit.js'
        ],
        dest: 'dist/heart-walk/js/pageEdit.' + '<%= timestamp %>' + '.min.js'
      }
    ]
  },

  "ym-primary": {
    files: [
      {
        src: [
          'dist/ym-primary/js/main.js'
        ],
        dest: 'dist/ym-primary/js/main.' + '<%= timestamp %>' + '.min.js'
      },
      {
        src: [
          'dist/ym-primary/js/participant.js'
        ],
        dest: 'dist/ym-primary/js/participant.' + '<%= timestamp %>' + '.min.js'
      }
    ]
  },

  "middle-school": {
    files: [
      {
        src: [
          'dist/middle-school/js/main.js'
        ],
        dest: 'dist/middle-school/js/main.' + '<%= timestamp %>' + '.min.js'
      },
      {
        src: [
          'dist/middle-school/js/participant.js'
        ],
        dest: 'dist/middle-school/js/participant.' + '<%= timestamp %>' + '.min.js'
      }
    ]
  },

  "high-school": {
    files: [
      {
        src: [
          'dist/high-school/js/main.js'
        ],
        dest: 'dist/high-school/js/main.' + '<%= timestamp %>' + '.min.js'
      },
      {
        src: [
          'dist/high-school/js/participant.js'
        ],
        dest: 'dist/high-school/js/participant.' + '<%= timestamp %>' + '.min.js'
      }
    ]
  },

  "district-heart": {
    files: [
      {
        src: [
          'dist/district-heart/js/main.js'
        ],
        dest: 'dist/district-heart/js/main.' + '<%= timestamp %>' + '.min.js'
      },
      {
        src: [
          'dist/district-heart/js/participant.js'
        ],
        dest: 'dist/district-heart/js/participant.' + '<%= timestamp %>' + '.min.js'
      }
    ]
  },

  "nchw": {
    files: [
      {
        src: ["src/nchw/js/main.js"],
        dest: "dist/nchw/js/main." + "<%= timestamp %>" + ".min.js"
      }
    ]
  },

  "heartchase": {
    files: [
      {
        src: ["src/heartchase/js/main.js"],
        dest: "dist/heartchase/js/main." + "<%= timestamp %>" + ".min.js"
      }
    ]
  },

  "cyclenation": {
    files: [
      {
        src: ["src/cyclenation/js/main.js"],
        dest: "dist/cyclenation/js/main." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/cyclenation/js/pushy.js"],
        dest: "dist/cyclenation/js/pushy.min.js"
      }
    ]
  },

  "heartwalk2020": {
    files: [
      {
        src: ["src/heartwalk2020/js/main.js"],
        dest: "dist/heartwalk2020/js/main." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/heartwalk2020/js/registration.js"],
        dest: "dist/heartwalk2020/js/registration." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/heartwalk2020/js/donation.js"],
        dest: "dist/heartwalk2020/js/donation." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/heartwalk2020/js/pushy.js"],
        dest: "dist/heartwalk2020/js/pushy.min.js"
      }
    ]
  },

  "fieldday": {
    files: [
      {
        src: ["src/fieldday/js/main.js"],
        dest: "dist/fieldday/js/main." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/fieldday/js/registration.js"],
        dest: "dist/fieldday/js/registration." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/fieldday/js/donation.js"],
        dest: "dist/fieldday/js/donation." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/fieldday/js/pushy.js"],
        dest: "dist/fieldday/js/pushy.min.js"
      }
    ]
  },

  "heartwalklawyers": {
    files: [
      {
        src: ["src/heartwalklawyers/js/main.js"],
        dest: "dist/heartwalklawyers/js/main." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/heartwalklawyers/js/registration.js"],
        dest: "dist/heartwalklawyers/js/registration." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/heartwalklawyers/js/donation.js"],
        dest: "dist/heartwalklawyers/js/donation." + "<%= timestamp %>" + ".min.js"
      },
      {
        src: ["src/heartwalklawyers/js/pushy.js"],
        dest: "dist/heartwalklawyers/js/pushy.min.js"
      }
    ]
  }
}
