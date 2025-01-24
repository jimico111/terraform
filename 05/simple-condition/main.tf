variable "name" {
  description = "A name to render"
  type = string
}

output "output" {
    value = "Hello, %{if var.name != ""}${var.name}%{else}(unnamed)%{endif}"
}

output "output2" {
    value = (var.name != "" ? var.name : "(unnamed)")
}