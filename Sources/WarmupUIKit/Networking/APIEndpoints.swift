//
//  APIEndpoints.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 12/17/25.
//

import Foundation

public struct APIEndpoints {
    public static var baseURL: String = ""

    // MARK: - Authentication
    public struct Auth {
        public static var login: String { "\(baseURL)/v1/users/login" }
        public static var logout: String { "\(baseURL)/v1/users/logout" }
        public static var logoutAll: String { "\(baseURL)/v1/users/logout-all" }
        public static var refresh: String { "\(baseURL)/v1/users/refresh" }
        public static var refreshToken: String { "\(baseURL)/v1/users/refresh" }
        public static var me: String { "\(baseURL)/v1/users/me" }
        public static var changePassword: String { "\(baseURL)/v1/users/change-password" }
        public static var forgotPassword: String { "\(baseURL)/v1/users/forgot-password" }
        public static var resetPassword: String { "\(baseURL)/v1/users/reset-password" }
        public static var verifyEmail: String { "\(baseURL)/v1/users/verify-email" }

        // Registration
        public static var registerTrainer: String { "\(baseURL)/v1/users/register/trainer" }
        public static var registerClient: String { "\(baseURL)/v1/users/register" }
        public static var signupWithInvitation: String { "\(baseURL)/v1/invitations/signup" }

        // Phone/OTP Authentication
        public static var sendOtp: String { "\(baseURL)/v1/auth/otp/send" }
        public static var verifyOtp: String { "\(baseURL)/v1/auth/otp/verify" }
        public static var sendLinkPhoneOtp: String { "\(baseURL)/v1/auth/phone/send-otp" }
        public static var verifyAndLinkPhone: String { "\(baseURL)/v1/auth/phone/verify" }
    }

    // MARK: - Users
    public struct Users {
        public static var profile: String { "\(baseURL)/v1/users/me" }
        public static var clients: String { "\(baseURL)/v1/users/clients" }
        public static var trainers: String { "\(baseURL)/v1/users/trainers" }
        public static var searchTrainers: String { "\(baseURL)/v1/users/trainers/search" }
        public static var search: String { "\(baseURL)/v1/users/search" }
        public static var timezone: String { "\(baseURL)/v1/users/timezone" }

        public static func updateProfile(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)"
        }

        public static func getUser(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)"
        }

        public static func deleteUser(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)"
        }

        public static func uploadAvatar(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)/avatar"
        }

        // Client-Trainer relationships
        public static func assignTrainer(_ clientId: String) -> String {
            "\(baseURL)/v1/users/\(clientId)/trainer"
        }

        public static func removeTrainer(_ clientId: String) -> String {
            "\(baseURL)/v1/users/\(clientId)/trainer"
        }

        // Get client statistics
        public static func statistics(_ clientId: String) -> String {
            return "\(baseURL)/v1/users/\(clientId)/statistics"
        }

        // User invitations (different from general invitations)
        public static let userInvitations = "\(baseURL)/v1/users/invitations"

        // Get invitations with status filter
        public static func invitationsByStatus(_ status: String) -> String {
            return "\(baseURL)/v1/users/invitations?status=\(status)"
        }

        // Get invitation statistics
        public static let invitationStats = "\(baseURL)/v1/users/invitations/stats"

        // Revoke invitation by code
        public static func revokeInvitation(_ code: String) -> String {
            return "\(baseURL)/v1/users/invitations/\(code)"
        }
    }

    // MARK: - Programs
    public struct Programs {
        public static var list: String { "\(baseURL)/v1/programs" }
        public static var create: String { "\(baseURL)/v1/programs" }
        public static var myPrograms: String { "\(baseURL)/v1/programs/my" }
        public static var activeProgram: String { "\(baseURL)/v1/programs/active" }
        public static var archived: String { "\(baseURL)/v1/programs/archived" }

        public static func detail(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)"
        }

        public static func update(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)"
        }

        public static func delete(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)"
        }

        public static func duplicate(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/duplicate"
        }

        public static func archive(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/archive"
        }

        public static func unarchive(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/unarchive"
        }

        // Assignment
        public static func assign(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/assign"
        }

        public static func unassign(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/unassign"
        }

        public static func assignedClients(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/clients"
        }

        // Invitations
        public static func sendInvitation(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/invite"
        }

        public static func acceptInvitation(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/accept"
        }

        public static func declineInvitation(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/decline"
        }

        // Progress
        public static func progress(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/progress"
        }

        public static func stats(_ id: String) -> String {
            "\(baseURL)/v1/programs/\(id)/stats"
        }

        // Get all workouts for a program
       public static func workouts(_ programId: String) -> String {
           "\(baseURL)/v1/programs/\(programId)/workouts"
       }

       // Get workout statistics for a program
       public static func workoutStats(_ programId: String) -> String {
           "\(baseURL)/v1/programs/\(programId)/stats"
       }
    }


    // MARK: - Workouts
    public struct Workouts {
        public static let base = "\(baseURL)/v1/workouts"
        public static var list: String { "\(baseURL)/v1/workouts" }
        public static var create: String { "\(baseURL)/v1/workouts" }
        public static var upcoming: String { "\(baseURL)/v1/workouts/upcoming" }
        public static var saved: String { "\(baseURL)/v1/workouts/saved" }
        public static var scheduled: String { "\(baseURL)/v1/workouts/scheduled" }
        public static var history: String { "\(baseURL)/v1/workouts/history" }
        public static var today: String { "\(baseURL)/v1/workouts/today" }
        public static var fromNotes : String { "\(baseURL)/v1/workouts/from-notes" }
        public static var structured: String {"\(baseURL)/v1/workouts/structured" }

        // AI Generation
        public static var generateFromNotes: String { "\(baseURL)/v1/workouts/generate-from-notes" }
        public static var aiSuggest: String { "\(baseURL)/v1/workouts/ai/suggest" }

        public static func detail(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)"
        }

        public static func update(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)"
        }

        public static func delete(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)"
        }

        public static func duplicate(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/duplicate"
        }

        public static func save(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/save"
        }

        public static func unsave(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/unsave"
        }

        public static func remix(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/remix"
        }

        public static func proposeSchedule(id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/propose-schedule"
        }

        public static func acceptSchedule(id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/accept-schedule"
        }

        public static func complete(id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/complete"
        }

        public static func reschedule(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/reschedule"
        }

        public static func start(_ id: String) -> String {
            "\(baseURL)/v1/workout-sessions/\(id)/start"
        }

        public static func completeSession(_ id: String) -> String {
            "\(baseURL)/v1/workout-sessions/\(id)/complete"
        }

        public static func pause(_ id: String) -> String {
            "\(baseURL)/v1/workout-sessions/\(id)/pause"
        }

        public static func resume(_ id: String) -> String {
            "\(baseURL)/v1/workout-sessions/\(id)/resume"
        }

        public static func cancel(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/cancel"
        }

        public static func log(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/log"
        }

        public static func updateLog(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/log"
        }

        public static func feedback(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/feedback"
        }

        public static func rate(_ id: String) -> String {
            "\(baseURL)/v1/workouts/\(id)/rate"
        }

        public static func batch(ids: [String]) -> String {
            let idsString = ids.joined(separator: ",")
            return "\(baseURL)/v1/workouts/batch?ids=\(idsString)"
        }

        public static func byProgram(_ programId: String) -> String {
            "\(baseURL)/v1/workouts/program/\(programId)"
        }
    }

    // MARK: - Scheduling & Proposals
    public struct Schedule {
        public static var upcoming: String { "\(baseURL)/v1/schedule/upcoming" }
        public static var calendar: String { "\(baseURL)/v1/schedule/calendar" }
        public static var availability: String { "\(baseURL)/v1/schedule/availability" }
        public static var conflicts: String { "\(baseURL)/v1/schedule/conflicts" }
        public static var schedule: String { "\(baseURL)/v1/workouts/schedule" }
        public static var bulkSchedule: String { "\(baseURL)/v1/workouts/schedule/bulk" }
        public static var proposeReschedule: String { "\(baseURL)/v1/workouts/propose-reschedule" }
        public static var proposals: String { "\(baseURL)/v1/workouts/proposals" }
        public static var pendingProposals: String { "\(baseURL)/v1/workouts/proposals/pending" }

        public static func proposeTime(_ workoutId: String) -> String {
            "\(baseURL)/v1/workouts/\(workoutId)/propose-time"
        }

        public static func acceptProposal(_ proposalId: String) -> String {
            "\(baseURL)/v1/workouts/proposals/\(proposalId)/accept"
        }

        public static func declineProposal(_ proposalId: String) -> String {
            "\(baseURL)/v1/workouts/proposals/\(proposalId)/decline"
        }

        public static func counterProposal(_ proposalId: String) -> String {
            "\(baseURL)/v1/workouts/proposals/\(proposalId)/counter"
        }

        public static var recurringSchedules: String { "\(baseURL)/v1/schedule/recurring" }
        public static var createRecurring: String { "\(baseURL)/v1/schedule/recurring" }

        public static func updateRecurring(_ id: String) -> String {
            "\(baseURL)/v1/schedule/recurring/\(id)"
        }

        public static func deleteRecurring(_ id: String) -> String {
            "\(baseURL)/v1/schedule/recurring/\(id)"
        }
    }

    // MARK: - Exercises
    public struct Exercises {
        public static var list: String { "\(baseURL)/v1/exercises" }
        public static var search: String { "\(baseURL)/v1/exercises/search" }
        public static var categories: String { "\(baseURL)/v1/exercises/categories" }
        public static var muscleGroups: String { "\(baseURL)/v1/exercises/muscle-groups" }
        public static var equipment: String { "\(baseURL)/v1/exercises/equipment" }
        public static var custom: String { "\(baseURL)/v1/exercises/custom" }
        public static var favorites: String { "\(baseURL)/v1/exercises/favorites" }
        public static var difficulty: String { "\(baseURL)/v1/exercises/difficulty" }
        public static var upload: String { "\(baseURL)/v1/exercises/upload" }
        public static var detect: String { "\(baseURL)/v1/exercises/detect" }

        public static func detail(_ id: String) -> String {
            "\(baseURL)/v1/exercises/\(id)"
        }

        public static func byCategory(_ category: String) -> String {
            "\(baseURL)/v1/exercises/category/\(category)"
        }

        public static func byMuscleGroup(_ group: String) -> String {
            "\(baseURL)/v1/exercises/muscle-group/\(group)"
        }

        public static func byEquipment(_ equipment: String) -> String {
            "\(baseURL)/v1/exercises/equipment/\(equipment)"
        }

        public static var createCustom: String { "\(baseURL)/v1/exercises/custom" }

        public static func updateCustom(_ id: String) -> String {
            "\(baseURL)/v1/exercises/custom/\(id)"
        }

        public static func deleteCustom(_ id: String) -> String {
            "\(baseURL)/v1/exercises/custom/\(id)"
        }

        public static func addFavorite(_ id: String) -> String {
            "\(baseURL)/v1/exercises/\(id)/favorite"
        }

        public static func removeFavorite(_ id: String) -> String {
            "\(baseURL)/v1/exercises/\(id)/unfavorite"
        }

        public static func update(_ id: String) -> String {
            return "/v1/exercises/\(id)"
        }

        public static func delete(_ id: String) -> String {
            return "/v1/exercises/\(id)"
        }
    }

    // MARK: - Invitations
    public struct Invitations {
        public static var create: String { "\(baseURL)/v1/invitations" }
        public static var validate: String { "\(baseURL)/v1/invitations/validate" }
        public static var myInvitations: String { "\(baseURL)/v1/invitations" }
        public static var sent: String { "\(baseURL)/v1/invitations/sent" }
        public static var received: String { "\(baseURL)/v1/invitations/received" }
        public static var stats: String { "\(baseURL)/v1/invitations/stats" }

        public static func revoke(_ code: String) -> String {
            "\(baseURL)/v1/invitations/\(code)"
        }

        public static func resend(_ code: String) -> String {
            "\(baseURL)/v1/invitations/\(code)/resend"
        }

        public static func accept(_ code: String) -> String {
            "\(baseURL)/v1/invitations/\(code)/accept"
        }

        public static func decline(_ code: String) -> String {
            "\(baseURL)/v1/invitations/\(code)/decline"
        }
    }

    // MARK: - Notifications
    public struct Notifications {
        public static var list: String { "\(baseURL)/v1/notifications" }
        public static var unread: String { "\(baseURL)/v1/notifications/unread" }
        public static var count: String { "\(baseURL)/v1/notifications/unread/count" }
        public static var preferences: String { "\(baseURL)/v1/notifications/preferences" }
        public static var updatePreferences: String { "\(baseURL)/v1/notifications/preferences" }
        public static var registerDevice: String { "\(baseURL)/v1/notifications/device-token" }

        public static func removeDevice(_ tokenId: String) -> String {
            "\(baseURL)/v1/notifications/device-token/\(tokenId)"
        }

        public static func markRead(_ id: String) -> String {
            "\(baseURL)/v1/notifications/\(id)/read"
        }

        public static var markAllRead: String { "\(baseURL)/v1/notifications/read-all" }

        public static func delete(_ id: String) -> String {
            "\(baseURL)/v1/notifications/\(id)"
        }

        public static var pushSettings: String { "\(baseURL)/v1/notifications/push-settings" }
        public static var updatePushSettings: String { "\(baseURL)/v1/notifications/push-settings" }
        public static var subscriptions: String { "\(baseURL)/v1/notifications/subscriptions" }

        public static func subscribe(_ type: String) -> String {
            "\(baseURL)/v1/notifications/subscribe/\(type)"
        }

        public static func unsubscribe(_ type: String) -> String {
            "\(baseURL)/v1/notifications/unsubscribe/\(type)"
        }
    }

    // MARK: - Journal
    public struct Journal {
        public static var entries: String { "\(baseURL)/v1/journal/entries" }
        public static var create: String { "\(baseURL)/v1/journal/entries" }
        public static var tags: String { "\(baseURL)/v1/journal/tags" }
        public static var moods: String { "\(baseURL)/v1/journal/moods" }
        public static var stats: String { "\(baseURL)/v1/journal/stats" }

        public static func entry(_ id: String) -> String {
            "\(baseURL)/v1/journal/entries/\(id)"
        }

        public static func update(_ id: String) -> String {
            "\(baseURL)/v1/journal/entries/\(id)"
        }

        public static func delete(_ id: String) -> String {
            "\(baseURL)/v1/journal/entries/\(id)"
        }

        public static func byDate(_ date: String) -> String {
            "\(baseURL)/v1/journal/entries/date/\(date)"
        }

        public static func byTag(_ tag: String) -> String {
            "\(baseURL)/v1/journal/entries/tag/\(tag)"
        }

        public static func byMood(_ mood: String) -> String {
            "\(baseURL)/v1/journal/entries/mood/\(mood)"
        }
    }

    // MARK: - Search
    public struct Search {
        public static func clients(query: String, page: Int = 0, size: Int = 20) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return "\(baseURL)/v1/search/clients?q=\(encoded)&page=\(page)&size=\(size)"
        }

        public static func exercises(query: String, category: String? = nil) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            var url = "\(baseURL)/v1/search/exercises?q=\(encoded)"
            if let cat = category {
                url += "&category=\(cat)"
            }
            return url
        }

        public static func programs(query: String, clientId: String? = nil) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            var url = "\(baseURL)/v1/search/programs?q=\(encoded)"
            if let id = clientId {
                url += "&clientId=\(id)"
            }
            return url
        }

        public static func workouts(query: String, clientId: String? = nil, programId: String? = nil) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            var url = "\(baseURL)/v1/search/workouts?q=\(encoded)"
            if let id = clientId {
                url += "&clientId=\(id)"
            }
            if let programId = programId {
                url += "&programId=\(programId)"
            }
            return url
        }

        public static func journals(query: String, clientId: String? = nil, workoutId: String? = nil) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            var url = "\(baseURL)/v1/search/journals?q=\(encoded)"
            if let id = clientId {
                url += "&clientId=\(id)"
            }
            if let workoutId = workoutId {
                url += "&workoutId=\(workoutId)"
            }
            return url
        }

        public static func all(query: String, type: String? = nil) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            var url = "\(baseURL)/v1/search/all?q=\(encoded)"
            if let type = type {
                url += "&type=\(type)"
            }
            return url
        }

        public static func byDateRange(
            entity: String,
            startDate: Date? = nil,
            endDate: Date? = nil,
            clientId: String? = nil
        ) -> String {
            var url = "\(baseURL)/v1/search/\(entity)/by-date?"

            let formatter = ISO8601DateFormatter()
            if let start = startDate {
                url += "startDate=\(formatter.string(from: start))&"
            }
            if let end = endDate {
                url += "endDate=\(formatter.string(from: end))&"
            }
            if let id = clientId {
                url += "clientId=\(id)"
            }

            return url.hasSuffix("&") || url.hasSuffix("?")
                ? String(url.dropLast())
                : url
        }

        public static func schedule(
            date: Date? = nil,
            week: Int? = nil,
            month: Int? = nil,
            year: Int? = nil
        ) -> String {
            var url = "\(baseURL)/v1/search/schedule?"

            let formatter = ISO8601DateFormatter()
            if let date = date {
                url += "date=\(formatter.string(from: date))&"
            }
            if let week = week {
                url += "week=\(week)&"
            }
            if let month = month {
                url += "month=\(month)&"
            }
            if let year = year {
                url += "year=\(year)"
            }

            return url.hasSuffix("&") || url.hasSuffix("?")
                ? String(url.dropLast())
                : url
        }

        public static func search(
            query: String,
            type: String? = nil,
            page: Int = 0,
            size: Int = 20
        ) -> String {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            var url = "\(baseURL)/v1/search?q=\(encoded)&page=\(page)&size=\(size)"
            if let type = type {
                url += "&type=\(type)"
            }
            return url
        }
    }

    // MARK: - Messages/Chat
    public struct Messages {
        public static var conversations: String { "\(baseURL)/v1/messages/conversations" }
        public static var unread: String { "\(baseURL)/v1/messages/unread" }
        public static var send: String { "\(baseURL)/v1/messages/send" }

        public static func conversation(_ userId: String) -> String {
            "\(baseURL)/v1/messages/conversations/\(userId)"
        }

        public static func messages(_ conversationId: String) -> String {
            "\(baseURL)/v1/messages/conversations/\(conversationId)/messages"
        }

        public static func markRead(_ conversationId: String) -> String {
            "\(baseURL)/v1/messages/conversations/\(conversationId)/read"
        }

        public static func delete(_ messageId: String) -> String {
            "\(baseURL)/v1/messages/\(messageId)"
        }

        public static func typing(_ conversationId: String) -> String {
            "\(baseURL)/v1/messages/conversations/\(conversationId)/typing"
        }
    }

    // MARK: - Social Feed
    public struct SocialFeed {
        public static var home: String { "\(baseURL)/v1/feed/home" }
        public static var myActivity: String { "\(baseURL)/v1/feed/me" }
        public static var global: String { "\(baseURL)/v1/feed/global" }
        public static var coach: String { "\(baseURL)/v1/feed/coach" }

        public static func homeFeed(page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/home?page=\(page)&size=\(size)"
        }

        public static func myActivityFeed(page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/me?page=\(page)&size=\(size)"
        }

        public static func globalFeed(page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/global?page=\(page)&size=\(size)"
        }

        public static func coachFeed(page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/coach?page=\(page)&size=\(size)"
        }

        public static func userProfileFeed(_ userId: String, page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/user/\(userId)?page=\(page)&size=\(size)"
        }

        public static func shareableWorkouts(page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/shareable-workouts?page=\(page)&size=\(size)"
        }

        public static var createPost: String { "\(baseURL)/v1/feed/posts" }
        public static var createShoutout: String { "\(baseURL)/v1/feed/posts/shoutout" }

        public static func post(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)"
        }

        public static func deletePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)"
        }

        public static func hidePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)/hide"
        }

        public static func updateVisibility(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)/visibility"
        }

        public static func updateCaption(_ id: String, caption: String) -> String {
            let encoded = caption.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? caption
            return "\(baseURL)/v1/feed/posts/\(id)/caption?caption=\(encoded)"
        }

        public static func likePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)/like"
        }

        public static func unlikePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)/like"
        }

        public static func congratsPost(_ id: String, reactionType: String? = nil) -> String {
            var url = "\(baseURL)/v1/feed/posts/\(id)/congrats"
            if let reaction = reactionType {
                url += "?reactionType=\(reaction)"
            }
            return url
        }

        public static func comments(_ postId: String, page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/comments?page=\(page)&size=\(size)"
        }

        public static func addComment(_ postId: String) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/comment"
        }

        public static func deleteComment(_ postId: String, commentId: String) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/comments/\(commentId)"
        }

        public static var privacySettings: String { "\(baseURL)/v1/feed/privacy" }

        public static func muteUser(_ userId: String) -> String {
            "\(baseURL)/v1/feed/privacy/mute/\(userId)"
        }

        public static func unmuteUser(_ userId: String) -> String {
            "\(baseURL)/v1/feed/privacy/mute/\(userId)"
        }

        public static func blockUser(_ userId: String) -> String {
            "\(baseURL)/v1/feed/privacy/block/\(userId)"
        }

        public static func unblockUser(_ userId: String) -> String {
            "\(baseURL)/v1/feed/privacy/block/\(userId)"
        }

        public static var mutedUsers: String { "\(baseURL)/v1/feed/privacy/muted" }
        public static var blockedUsers: String { "\(baseURL)/v1/feed/privacy/blocked" }

        public static func postLikers(_ postId: String, page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/likes?page=\(page)&size=\(size)"
        }

        public static func shareCard(_ postId: String) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/share"
        }

        public static func reportPost(_ postId: String) -> String {
            "\(baseURL)/v1/feed/reports/post/\(postId)"
        }

        public static func reportComment(_ commentId: String) -> String {
            "\(baseURL)/v1/feed/reports/comment/\(commentId)"
        }

        public static func reportUser(_ userId: String) -> String {
            "\(baseURL)/v1/feed/reports/user/\(userId)"
        }
    }

    // MARK: - Friends/Follow System
    public struct Follows {
        private static var base: String { "\(baseURL)/v1/social/follows" }

        public static func follow(_ userId: String) -> String {
            "\(base)/\(userId)"
        }

        public static func unfollow(_ userId: String) -> String {
            "\(base)/\(userId)"
        }

        public static func checkStatus(_ userId: String) -> String {
            "\(base)/check/\(userId)"
        }

        public static func myFollowers(page: Int = 0, size: Int = 20) -> String {
            "\(base)/followers?page=\(page)&size=\(size)"
        }

        public static func myFollowing(page: Int = 0, size: Int = 20) -> String {
            "\(base)/following?page=\(page)&size=\(size)"
        }

        public static func pendingRequests(page: Int = 0, size: Int = 20) -> String {
            "\(base)/requests?page=\(page)&size=\(size)"
        }

        public static func acceptRequest(_ requestId: String) -> String {
            "\(base)/requests/\(requestId)/accept"
        }

        public static func declineRequest(_ requestId: String) -> String {
            "\(base)/requests/\(requestId)/decline"
        }

        public static func removeFollower(_ followerId: String) -> String {
            "\(base)/followers/\(followerId)"
        }

        public static var myStats: String {
            "\(base)/stats"
        }

        public static func userFollowers(_ userId: String, page: Int = 0, size: Int = 20) -> String {
            "\(base)/users/\(userId)/followers?page=\(page)&size=\(size)"
        }

        public static func userFollowing(_ userId: String, page: Int = 0, size: Int = 20) -> String {
            "\(base)/users/\(userId)/following?page=\(page)&size=\(size)"
        }

        public static func userStats(_ userId: String) -> String {
            "\(base)/users/\(userId)/stats"
        }
    }

    // MARK: - Feed/Social (Legacy)
    public struct Feed {
        public static var timeline: String { "\(baseURL)/v1/feed" }
        public static var posts: String { "\(baseURL)/v1/feed/posts" }
        public static var createPost: String { "\(baseURL)/v1/feed/posts" }
        public static var trending: String { "\(baseURL)/v1/feed/trending" }
        public static var following: String { "\(baseURL)/v1/feed/following" }

        public static func post(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)"
        }

        public static func updatePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)"
        }

        public static func deletePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)"
        }

        public static func likePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)/like"
        }

        public static func unlikePost(_ id: String) -> String {
            "\(baseURL)/v1/feed/posts/\(id)/unlike"
        }

        public static func comments(_ postId: String) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/comments"
        }

        public static func addComment(_ postId: String) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/comments"
        }

        public static func share(_ postId: String) -> String {
            "\(baseURL)/v1/feed/posts/\(postId)/share"
        }

        public static func follow(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)/follow"
        }

        public static func unfollow(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)/unfollow"
        }

        public static func followers(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)/followers"
        }

        public static func following(_ userId: String) -> String {
            "\(baseURL)/v1/users/\(userId)/following"
        }
    }

    // MARK: - Personal Records
    public struct PersonalRecords {
        public static var list: String { "\(baseURL)/v1/personal-records" }
        public static var create: String { "\(baseURL)/v1/personal-records" }
        public static var recent: String { "\(baseURL)/v1/personal-records/recent" }
        public static var achievements: String { "\(baseURL)/v1/personal-records/achievements" }

        public static func byExercise(_ exerciseId: String) -> String {
            "\(baseURL)/v1/personal-records/exercise/\(exerciseId)"
        }

        public static func update(_ id: String) -> String {
            "\(baseURL)/v1/personal-records/\(id)"
        }

        public static func delete(_ id: String) -> String {
            "\(baseURL)/v1/personal-records/\(id)"
        }
    }

    // MARK: - Milestones
    public struct Milestones {
        public static func list(page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/milestones?page=\(page)&size=\(size)"
        }

        public static var unacknowledged: String { "\(baseURL)/v1/milestones/unacknowledged" }
        public static var stats: String { "\(baseURL)/v1/milestones/stats" }
        public static var streak: String { "\(baseURL)/v1/milestones/streak" }
        public static var prs: String { "\(baseURL)/v1/milestones/prs" }

        public static func byType(_ type: String, page: Int = 0, size: Int = 20) -> String {
            "\(baseURL)/v1/milestones/by-type/\(type)?page=\(page)&size=\(size)"
        }

        public static func forWorkout(_ workoutId: String) -> String {
            "\(baseURL)/v1/milestones/workout/\(workoutId)"
        }

        public static func acknowledge(_ milestoneId: String) -> String {
            "\(baseURL)/v1/milestones/\(milestoneId)/acknowledge"
        }

        public static var acknowledgeAll: String { "\(baseURL)/v1/milestones/acknowledge-all" }

        public static func share(_ milestoneId: String) -> String {
            "\(baseURL)/v1/milestones/\(milestoneId)/share"
        }
    }

    // MARK: - Analytics
    public struct Analytics {
        public static var dashboard: String { "\(baseURL)/v1/analytics/dashboard" }
        public static var progress: String { "\(baseURL)/v1/analytics/progress" }
        public static var workoutStats: String { "\(baseURL)/v1/analytics/workouts" }
        public static var exerciseStats: String { "\(baseURL)/v1/analytics/exercises" }
        public static var clientStats: String { "\(baseURL)/v1/analytics/clients" }
        public static var revenue: String { "\(baseURL)/v1/analytics/revenue" }

        public static func userAnalytics(_ userId: String) -> String {
            "\(baseURL)/v1/analytics/users/\(userId)"
        }

        public static func programAnalytics(_ programId: String) -> String {
            "\(baseURL)/v1/analytics/programs/\(programId)"
        }

        public static func dateRange(_ start: String, _ end: String) -> String {
            "\(baseURL)/v1/analytics/range?start=\(start)&end=\(end)"
        }
    }

    // MARK: - Settings
    public struct Settings {
        public static var app: String { "\(baseURL)/v1/settings/app" }
        public static var profile: String { "\(baseURL)/v1/settings/profile" }
        public static var privacy: String { "\(baseURL)/v1/settings/privacy" }
        public static var notifications: String { "\(baseURL)/v1/settings/notifications" }
        public static var units: String { "\(baseURL)/v1/settings/units" }
        public static var updateUnits: String { "\(baseURL)/v1/settings/units" }
    }

    // MARK: - Health & System
    public struct Health {
        public static var status: String { "\(baseURL.replacingOccurrences(of: "/api", with: ""))/health/status" }
        public static var info: String { "\(baseURL.replacingOccurrences(of: "/api", with: ""))/health/info" }
        public static var ping: String { "\(baseURL.replacingOccurrences(of: "/api", with: ""))/ping" }
    }

    // MARK: - Media/Files
    public struct Media {
        public static var upload: String { "\(baseURL)/v1/media/upload" }
        public static var uploadImage: String { "\(baseURL)/v1/media/upload/image" }
        public static var uploadVideo: String { "\(baseURL)/v1/media/upload/video" }
        public static var download: String { "\(baseURL)/v1/media/download" }

        public static func downloadById(_ fileId: String) -> String {
            "\(baseURL)/v1/media/\(fileId)"
        }

        public static func delete(_ fileId: String) -> String {
            "\(baseURL)/v1/media/\(fileId)"
        }
    }

    public struct Journals {
           public static let base = "\(baseURL)/v1/journals"
           public static let create = "\(baseURL)/v1/journals"
           public static let entries = "\(baseURL)/v1/journals/entries"
           public static let recent = "\(baseURL)/v1/journals/recent"

           public static func byClient(_ clientId: String) -> String {
               return "\(baseURL)/v1/journals/client/\(clientId)"
           }

           public static func journalByWorkout(_ workoutId: String) -> String {
               return "\(baseURL)/v1/journals/workout/\(workoutId)"
           }

           public static func details(_ id: String) -> String {
               return "\(baseURL)/v1/journals/\(id)"
           }

           public static func addComment(_ journalId: String) -> String {
               return "\(baseURL)/v1/journals/\(journalId)/comments"
           }

           public static func byDateRange(clientId: String, startDate: String, endDate: String) -> String {
               return "\(baseURL)/v1/journals/client/\(clientId)/range?start=\(startDate)&end=\(endDate)"
           }

           public static func review(_ id: String) -> String {
               return "\(baseURL)/v1/journals/\(id)/review"
           }

           public static func journalDetails(_ id: String) -> String {
               return "\(baseURL)/v1/journals/\(id)"
           }

           public static func update(_ id: String) -> String {
               return "\(baseURL)/v1/journals/\(id)"
           }

           public static func delete(_ id: String) -> String {
               return "\(baseURL)/v1/journals/\(id)"
           }

           public static func byWorkout(_ workoutId: String) -> String {
               return "\(baseURL)/v1/journals?workoutId=\(workoutId)"
           }

           public static func byUser(_ userId: String) -> String {
               return "\(baseURL)/v1/journals?userId=\(userId)"
           }
       }

}
