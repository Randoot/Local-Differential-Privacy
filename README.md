# Local-Differential-Privacy
This is a privacy-preserving model that sanitizes the collection of user information from a social network utilizing restricted local differential privacy (LDP) to save synthetic copies of collected data.
The file PCA Senders and receivers contains a dataset of communication patterns for 400 users in a period of 10 days.
The file CalculateAVGerror does the following: It computes the salient points in each user's communicarion pattern, then generates Laplacian noise acording to epsilon, it adds the noise to the selected salient points (SP), which will be sent to the server. Further , it reconstruct the original pattern form the niosed SP using linear estimation. It calculates the average error from the reconstruction process.
