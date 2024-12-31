# Use an official Golang image as the base
FROM golang:1.23-alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go Modules manifests
COPY go.mod ./

# Download the Go modules dependencies
RUN go mod tidy

# Copy the entire Go project
COPY . .

# Build the Go app
RUN go build -o main .

# Start a new stage from scratch (distroless base image)
FROM alpine:latest

# Install necessary certificates and dependencies
RUN apk --no-cache add ca-certificates

# Set the Current Working Directory inside the container
WORKDIR /root/

# Copy the pre-built binary file from the 'builder' stage
COPY --from=builder /app/main .

# Expose the port the app will run on
EXPOSE 8080

# Run the binary
CMD ["./main"]
