module.exports = {
    apps: [{
        name: "TerminalSocket",
        script: "app.js",
        watch: false,
        max_memory_restart: "2G",
        exp_backoff_restart_delay: 100,
        max_restarts: 10,
        restart_delay: 5000,
        kill_timeout: 3000,
        env: {
            NODE_ENV: "production"
        },
        log_date_format: "YYYY-MM-DD HH:mm:ss Z",
        error_file: "./logs/pm2-error.log",
        out_file: "./logs/pm2-out.log",
        merge_logs: true,
        autorestart: true
    }]
};