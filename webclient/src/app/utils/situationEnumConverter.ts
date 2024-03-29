export function situationEnumConverter(situation: number): string {
    switch(situation) {
        case 0:
            return "Ativo";
        case 1:
            return "Inativo";
        case 2:
            return "Sem contato";
        default:
            return "Algo de erro ocorreu no programa";
    }
}