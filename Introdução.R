idade <- 15;
Nome <- "L";


mensagem <- paste("Seu nome é", Nome, "e vocẽ tem ", idade, " anos ")
cat(mensagem)

if (idade >= 46) {
    cat("Você é velho\n")
} else if (idade < 45 & idade >= 16) {
    cat("Você é jovem\n")
} else if (idade > 1 & idade <= 15) {
    cat("Você é criança\n")
} else {
    cat("nada\n")
}
