class PhoneValidator {
  static bool isValid(String phone) {
    // Remove any spaces or special characters
    final cleaned = phone.trim().replaceAll(RegExp(r'\s+'), '');
    
    // Check length is exactly 10
    if (cleaned.length != 10) return false;
    
    // Check if starts with 05, 06, or 07
    if (!cleaned.startsWith('05') && 
        !cleaned.startsWith('06') && 
        !cleaned.startsWith('07')) {
      return false;
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return false;
    
    return true;
  }
  
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required / رقم الهاتف مطلوب';
    }
    
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), '');
    
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits / رقم الهاتف يجب أن يتكون من 10 أرقام';
    }
    
    if (!cleaned.startsWith('05') && 
        !cleaned.startsWith('06') && 
        !cleaned.startsWith('07')) {
      return 'Phone number must start with 05, 06, or 07 / رقم الهاتف يجب أن يبدأ بـ 05 أو 06 أو 07';
    }
    
    return null;
  }
}