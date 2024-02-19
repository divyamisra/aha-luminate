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

  "fieldday2023": {
    files: [
      {
        expand: true,
        cwd: "src/fieldday2023/html/",
        src: ["**/*.*"],
        dest: "dist/fieldday2023/html/"
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
  },

  "leaders-for-life": {
    files: [
      {
        expand: true,
        cwd: "src/leaders-for-life/html/",
        src: ["**/*.*"],
        dest: "dist/leaders-for-life/html/"
      }
    ]
  },
  "social-stem": {
    files: [
      {
        expand: true,
        cwd: "src/social-stem/html/",
        src: ["**/*.*"],
        dest: "dist/social-stem/html/"
      }
    ]
  },
  "women-of-impact": {
    files: [
      {
        expand: true,
        cwd: "src/women-of-impact/html/",
        src: ["**/*.*"],
        dest: "dist/women-of-impact/html/"
      }
    ]
  },
  "teens-of-impact": {
    files: [
      {
        expand: true,
        cwd: "src/teens-of-impact/html/",
        src: ["**/*.*"],
        dest: "dist/teens-of-impact/html/"
      }
    ]
  }
}
