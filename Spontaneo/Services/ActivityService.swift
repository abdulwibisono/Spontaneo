import Firebase
import FirebaseFirestore

class ActivityService: ObservableObject {
    private let db = Firestore.firestore()
    
    func createActivity(_ activity: Activity) -> String? {
        do {
            var activityData = try Firestore.Encoder().encode(activity)
            
            // Ensure the location is stored as a GeoPoint
            if let latitude = activityData["location.latitude"] as? Double,
               let longitude = activityData["location.longitude"] as? Double {
                activityData["location"] = GeoPoint(latitude: latitude, longitude: longitude)
                activityData["location.name"] = activity.location.name
            }
            
            let docRef = try db.collection("activities").addDocument(data: activityData)
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
                do {
                    var data = queryDocumentSnapshot.data()
                    if let geoPoint = data["location"] as? GeoPoint {
                        data["location"] = [
                            "name": data["location.name"] as? String ?? "",
                            "latitude": geoPoint.latitude,
                            "longitude": geoPoint.longitude
                        ]
                    }
                    return try Firestore.Decoder().decode(Activity.self, from: data)
                } catch {
                    print("Error decoding activity: \(error)")
                    return nil
                }
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
}
