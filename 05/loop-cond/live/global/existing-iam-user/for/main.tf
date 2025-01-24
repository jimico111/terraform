###############################################################################
#
# list type variable
#

# ["neo" , "trinity", "morhpeus"]
variable "names" {
    default = ["neo" , "trinity", "morhpeus"]
    description = "List test"
    type = list(string)
}

# # ["neo" , "trinity", "morhpeus"]
output "names" {
    value = var.names
}

# #  ["NEO" , "TRINITY", "MORHPEUS"]
output "upper_names" {
    value = [for name in var.names: upper(name)]
}

output "short_upper_names" {
    value = [for name in var.names: upper(name) if length(name) < 5] 
}

###############################################################################
#
# map type
#

# {"neo": "hero", "trinity": "love interest", "morpheus": "mentor"}
variable "hero_thousand_faces" {
    default = {
        neo = "hero"
        trinity = "love interest"
        morhpeus = "mentor"
    }
    description = "Map test"
    type = map(string)
}

# {"neo": "hero", "trinity": "love interest", "morpheus": "mentor"}
output "name_role" {
    value = var.hero_thousand_faces
}

# ["neo is the hero", "trinity is the love interest", "morpheus is the mentor"]
output "bios" {
    value = [for name, role in var.hero_thousand_faces: "${name} is the ${role}"]
}

# ["NEO is the HERO", "TRINITY is the LOVE INTEREST", "MORPHEUS is the MENTOR"]
output "upper_bios" {
    value = [for name, role in var.hero_thousand_faces: "${upper(name)} is the ${upper(role)}"]
  
}

# {"NEO": "HERO", "TRINITY": "LOVE INTEREST", "MORPHEUS": "MENTOR"}
output "upper_bios_role" {
    value = {for name, role in var.hero_thousand_faces: upper(name) => upper(role)}
  
}
