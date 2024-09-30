import Firebase
import FirebaseFirestore

class ActivityService: ObservableObject {
    private let db = Firestore.firestore()
    
    func createActivity(_ activity: Activity) -> String? {
        do {
            let docRef = try db.collection("activities").addDocument(from: activity)
            return docRef.documentID
        } catch {
            print("Error adding activity: \(error)")
            return nil
        }
    }
    
    func getActivity(id: String, completion: @escaping (Activity?) -> Void) {
        db.collection("activities").document(id).getDocument { document, error in
            guard let document = document, document.exists else {
                completion(nil)
                return
            }
            
            do {
                let activity = try document.data(as: Activity.self)
                completion(activity)
            } catch {
                print("Error decoding activity: \(error)")
                completion(nil)
            }
        }
    }
    
    func updateActivity(_ activity: Activity) {
        guard let id = activity.id else { return }
        do {
            try db.collection("activities").document(id).setData(from: activity)
        } catch {
            print("Error updating activity: \(error)")
        }
    }
    
    func deleteActivity(id: String) {
        db.collection("activities").document(id).delete() { error in
            if let error = error {
                print("Error deleting activity: \(error)")
            }
        }
    }
    
    func getAllActivities(completion: @escaping ([Activity]) -> Void) {
        db.collection("activities").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching activities: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let activities = documents.compactMap { queryDocumentSnapshot -> Activity? in
                try? queryDocumentSnapshot.data(as: Activity.self)
            }
            completion(activities)
        }
    }
    
    func updateActivity(_ activity: Activity, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = activity.id else {
            completion(.failure(NSError(domain: "ActivityService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Activity ID is missing"])))
            return
        }
        
        do {
            try db.collection("activities").document(id).setData(from: activity) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func joinActivity(activityId: String, user: User) async throws {
            let activityRef = db.collection("activities").document(activityId)
            
            try await db.runTransaction { (transaction, errorPointer) -> Any? in
                let activityDocument: DocumentSnapshot
                do {
                    try activityDocument = transaction.getDocument(activityRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard var activity = try? activityDocument.data(as: Activity.self) else {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Activity does not exist"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                if activity.currentParticipants >= activity.maxParticipants {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Activity is full"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                let joinedUser = Activity.JoinedUser(id: user.id, username: user.username, fullName: user.fullName)
                if !activity.joinedUsers.contains(where: { $0.id == user.id }) {
                    activity.joinedUsers.append(joinedUser)
                    activity.currentParticipants += 1
                    
                    do {
                        try transaction.setData(from: activity, forDocument: activityRef)
                    } catch let error as NSError {
                        errorPointer?.pointee = error
                        return nil
                    }
                }
                
                return nil
            }
        }
        
    func leaveActivity(activityId: String, userId: String) async throws {
            let activityRef = db.collection("activities").document(activityId)
            
            try await db.runTransaction { (transaction, errorPointer) -> Any? in
                let activityDocument: DocumentSnapshot
                do {
                    try activityDocument = transaction.getDocument(activityRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard var activity = try? activityDocument.data(as: Activity.self) else {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Activity does not exist"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                if let index = activity.joinedUsers.firstIndex(where: { $0.id == userId }) {
                    activity.joinedUsers.remove(at: index)
                    activity.currentParticipants -= 1
                    
                    do {
                        try transaction.setData(from: activity, forDocument: activityRef)
                    } catch let error as NSError {
                        errorPointer?.pointee = error
                        return nil
                    }
                }
                
            return nil
        }
    }
}


