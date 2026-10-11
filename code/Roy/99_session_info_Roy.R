# =============================================================================
# Script: code/Roy/99_session_info_Roy.R
# Roy's copy (GitHub: royflum) of code/run/99_session_info.R.
#
# Purpose:
#   Save sessionInfo() for replication.
# =============================================================================

sink("tables/sessionInfo.txt")
print(sessionInfo())
sink()
cat("Saved tables/sessionInfo.txt\n")