import SwiftUI
import Observation
import Foundation

@Observable
final class ShareSheetViewModel {
    
    // MARK: - Dependencies
    // Usamos protocolos para mantener el desacoplamiento y facilitar el testing
    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
    
    // MARK: - State
    var email: String = "" {
        didSet {
            scheduleSearch() // Cada cambio de texto activa el cronómetro
        }
    }
    
    // Usuarios actualmente seleccionados para compartir
    var selectedUsers: [AppUser] = []
    
    // Sugerencias que vienen de la base de datos tras la búsqueda
    var suggestedUsers: [AppUser] = []
    
    // Listas de equipos
    var myTeams: [Team] = []
    var joinedTeams: [Team] = []
    
    // Selección de equipos por ID
    var selectedTeamIDs: Set<String> = []
    
    // Estado de carga y errores
    var isLoading = false
    var error: String?
    
    // Tarea de búsqueda para el debounce
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(teamRepository: any TeamRepository, userRepository: any UserRepository) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Data Loading
    func loadData() {
        // Evitamos doble carga si ya está en proceso
        guard !isLoading else { return }
        
        Task {
            isLoading = true
            error = nil
            
            do {
                // Ejecutamos las llamadas en paralelo para máxima velocidad
                async let myTeamsRequest = teamRepository.getTeamsUserOwns(userID: userID)
                async let joinedTeamsRequest = teamRepository.getTeamsUserIsIn(userID: userID)
                
                // Esperamos los resultados
                self.myTeams = try await myTeamsRequest
                self.joinedTeams = try await joinedTeamsRequest
                
            } catch {
                self.error = "Error al cargar equipos: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Search Logic (Debounce)
    private func scheduleSearch() {
        searchTask?.cancel() // Cancelamos la búsqueda anterior si el usuario sigue escribiendo
        
        guard email.count >= 3 else {
            self.suggestedUsers = []
            return
        }
        
        searchTask = Task {
            // Espera de 500ms antes de disparar la petición a Firebase
            try? await Task.sleep(for: .milliseconds(500))
            
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    
    @MainActor
    private func performSearch() async {
        do {
            // Llamamos al repositorio que usa el filtro \u{f8ff} de Firebase
            let results = try await userRepository.getUserSuggestionsByEmail(email: email)
            
            // Filtramos para no sugerir usuarios que ya están en la lista de seleccionados
            self.suggestedUsers = results.filter { candidate in
                !selectedUsers.contains(where: { $0.id == candidate.id })
            }
        } catch {
            print("Error en búsqueda: \(error)")
        }
    }
    
    // MARK: - Actions
    func addUser(_ user: AppUser) {
        if !selectedUsers.contains(where: { $0.id == user.id }) {
            selectedUsers.append(user)
        }
        email = "" // Limpia la búsqueda tras añadir
        suggestedUsers = []
    }
    
    func removeUser(_ user: AppUser) {
        selectedUsers.removeAll { $0.id == user.id }
    }
    
    func toggleSelection(_ team: Team) {
        if selectedTeamIDs.contains(team.id) {
            selectedTeamIDs.remove(team.id)
        } else {
            selectedTeamIDs.insert(team.id)
        }
    }
    
    func isSelected(_ team: Team) -> Bool {
        selectedTeamIDs.contains(team.id)
    }
    
    func confirmShare() {
        // Aquí implementarías la lógica final usando selectedUsers y selectedTeamIDs
        print("Compartiendo con \(selectedUsers.count) usuarios y \(selectedTeamIDs.count) equipos")
    }
    
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }
    
    // Helper temporal para el ID del usuario actual
    private func getCurrentUserID() -> String {
        // Esto debería venir de un AuthRepository
        return "current_user_id"
    }
}
