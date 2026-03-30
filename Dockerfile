# Specify the base image (check for the latest tag and specify if preferred)
FROM mcr.microsoft.com/playwright:v1.54.2-noble

# Set working directory (optional)
WORKDIR /app

# Install @playwright/mcp globally. Browsers are pre-installed in the base image — do not
# run `npx playwright install` here; it pulls a different version, removes existing browsers,
# and fails on ARM64 (Apple Silicon). Create non-root user for security.
RUN npm install -g @playwright/mcp@0.0.32 && \
    addgroup --system playwright && adduser --system --ingroup playwright --home /home/playwright playwright

# Copy the entrypoint script and set permissions
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh && \
    chown -R playwright:playwright /app && \
    mkdir -p /home/playwright/.npm && chown -R playwright:playwright /home/playwright

# Switch to non-root user
USER playwright

# Add health check to monitor container health
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f "@playwright/mcp" > /dev/null || exit 1

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
