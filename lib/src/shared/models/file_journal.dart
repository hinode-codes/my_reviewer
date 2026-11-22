typedef FileMove = ({String from, String to});

/// A move that passes through a temporary name on the way to its target.
typedef StagedMove = ({String from, String staging, String to});
