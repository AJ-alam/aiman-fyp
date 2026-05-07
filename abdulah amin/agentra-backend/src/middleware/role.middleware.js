const role = (requiredRole) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, msg: 'Unauthorized' });
    }
    if (req.user.role !== requiredRole) {
      return res.status(403).json({ success: false, msg: 'Forbidden: Access denied' });
    }
    next();
  };
};

module.exports = role;
