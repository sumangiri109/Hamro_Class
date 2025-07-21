const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const auth = admin.auth();

exports.deleteUnverifiedUsers = functions.pubsub
    .schedule("every 60 minutes")
    .onRun(async (context) => {
      try {
        let nextPageToken = undefined;
        let deletedCount = 0;

        do {
          const listUsersResult = await auth.listUsers(1000, nextPageToken);

          const usersToDelete = listUsersResult.users.filter((user) => {
            const createdAt = new Date(user.metadata.creationTime);
            const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);

            return !user.emailVerified && createdAt < oneHourAgo;
          });

          const deletePromises = usersToDelete.map((user) => {
            console.log(`Deleting user: ${user.uid} - ${user.email}`);
            deletedCount++;
            return auth.deleteUser(user.uid);
          });

          await Promise.all(deletePromises);

          nextPageToken = listUsersResult.pageToken;
        } while (nextPageToken);

        console.log(`Deleted ${deletedCount} 
          unverified users older than 1 hour.`);
        return null;
      } catch (error) {
        console.error("Error deleting unverified users:", error);
        return null;
      }
    });
