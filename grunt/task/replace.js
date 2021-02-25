/* jshint strict:false */

module.exports = {
  options: {
    patterns: [
      {
        match: 'buildTimestamp',
        replacement: '<%= timestamp %>'
      }
    ]
  },

  "general": {
    files: [
      {
        expand: true,
        cwd: 'src/general/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/general/html/"
      }
    ]
  },

  "heart-walk": {
    files: [
      {
        expand: true,
        cwd: 'src/heart-walk/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/heart-walk/html/"
      }
    ]
  },

  "youth-markets": {
    files: [
      {
        expand: true,
        cwd: 'src/youth-markets/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/youth-markets/html/"
      }
    ]
  },

  "ym-primary": {
    files: [
      {
        expand: true,
        cwd: 'src/ym-primary/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/ym-primary/html/"
      }
    ]
  },

  "middle-school": {
    files: [
      {
        expand: true,
        cwd: 'src/middle-school/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/middle-school/html/"
      }
    ]
  },

  "high-school": {
    files: [
      {
        expand: true,
        cwd: 'src/high-school/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/high-school/html/"
      }
    ]
  },

  "district-heart": {
    files: [
      {
        expand: true,
        cwd: 'src/district-heart/html/',
        src: [
          '**/*.*'
        ],
        dest: "dist/district-heart/html/"
      }
    ]
  },

  "nchw": {
    files: [
      {
        expand: true,
        cwd: "src/nchw/html/",
        src: ["**/*.*"],
        dest: "dist/nchw/html/"
      }
    ]
  },

  "heartchase": {
    files: [
      {
        expand: true,
        cwd: "src/heartchase/html/",
        src: ["**/*.*"],
        dest: "dist/heartchase/html/"
      }
    ]
  },

  "cyclenation": {
    files: [
      {
        expand: true,
        cwd: "src/cyclenation/html/",
        src: ["**/*.*"],
        dest: "dist/cyclenation/html/"
      }
    ]
  },

  "heartwalk2020": {
    files: [
      {
        expand: true,
        cwd: "src/heartwalk2020/html/",
        src: ["**/*.*"],
        dest: "dist/heartwalk2020/html/"
      }
    ]
  },

  "fieldday": {
    files: [
      {
        expand: true,
        cwd: "src/fieldday/html/",
        src: ["**/*.*"],
        dest: "dist/fieldday/html/"
      }
    ]
  },

  "heartwalklawyers": {
    files: [
      {
        expand: true,
        cwd: "src/heartwalklawyers/html/",
        src: ["**/*.*"],
        dest: "dist/heartwalklawyers/html/"
      }
    ]
  }
}
