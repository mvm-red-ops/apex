public class applicationException extends Exception {
	public String name;
    public String message;
    public Integer code;
    
    public applicationException(String name, String message, Integer code) {
        this.name = name;
        this.message = message;
        this.code = code;
    }
}