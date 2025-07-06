# Use the official lightweight Nginx image
FROM nginx:stable-alpine

# Remove the default greeting
RUN rm /usr/share/nginx/html/*

# Copy your site files into the container
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Default command (inherited from nginx image)
