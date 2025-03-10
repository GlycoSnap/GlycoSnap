# Use the official Flutter image
FROM ghcr.io/cirruslabs/flutter:3.29.1

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy the rest of the project files
COPY . .

# Expose the debug port
EXPOSE 8080

# Run the app in debug mode
CMD ["flutter", "run", "--debug", "--web-port", "8080"]