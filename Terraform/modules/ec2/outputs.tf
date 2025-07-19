output "instance_id" {
  description = "ID of the ChromaDB EC2 instance"
  value       = aws_instance.chromadb_instance.id
}

output "private_ip" {
  description = "Private IP of the ChromaDB EC2 instance"
  value       = aws_instance.chromadb_instance.private_ip
}
