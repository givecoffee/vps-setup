module.exports = {
  apps: [
    {
      name: 'coffee',
      script: './server.js',
      cwd: '/home/rae/apps/coffee',
      instances: 2,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      max_memory_restart: '200M',
      error_file: '/home/rae/logs/coffee-error.log',
      out_file: '/home/rae/logs/coffee-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss'
    },
    {
      name: 'portfolio',
      script: './server.js',
      cwd: '/home/rae/apps/portfolio',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      max_memory_restart: '150M',
      error_file: '/home/rae/logs/portfolio-error.log',
      out_file: '/home/rae/logs/portfolio-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss'
    },
    {
      name: 'w26',
      script: './server.js',
      cwd: '/home/rae/apps/w26',
      instances: 4,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3002
      },
      max_memory_restart: '300M',
      error_file: '/home/rae/logs/w26-error.log',
      out_file: '/home/rae/logs/w26-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss'
    }
  ]
};