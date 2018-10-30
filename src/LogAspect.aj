import org.aspectj.lang.Signature;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import org.aspectj.lang.reflect.MethodSignature;

public aspect LogAspect {

	private int _callDepth = -1;
	private String returnType = " ";
	ArrayList<ArrayList<String>> traceArray = new ArrayList<ArrayList<String>>();
	ArrayList<String> contentArray;
	ArrayList<String> argsArray;
	ArrayList<String> argsValues;
	Object target;
	String traceBefore = "";
	FileWriter fileWriter ;
	File file2;
	FileWriter fileWriter2 ;
	Class[] paramTypes;
	int i=0;

	public LogAspect(){
		file2 = new File("Trace1.csv");
		try {
			fileWriter2 = new FileWriter(file2);
			fileWriter2.write("");
			fileWriter2.write("Event timestamp,Event ID,Event type,Calling object,Calling object identity hashcode,Method return type,Method name,Method call depth,Method parameters number,Parameters types,Parameters values\n");
			fileWriter2.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

//	pointcut traceMethods(): !within(LogAspect)	&& !initialization(* .new(..)) ;
	pointcut traceMethods(): 
		//execution(* MyLine.*(..)) &&
		//!preinitialization(* .new(..)) && 
		//!staticinitialization(*) &&
		//!get(* .) &&
		//!set(* .) &&
		!within(testAspectBefore) && !within(MySecurityManager) && !within(JavaFX_OpenFile) && !within(Trace) &&
		!within(ca.uqac..*)&& !call (* ca.uqac..*(..)) && !within(SecurityProcessors.*)&& !call (* SecurityProcessors..*(..)) 
		&& !initialization(* .new(..)) ;

	before(): traceMethods() {

		_callDepth++;
		try {
			fileWriter2.write("");
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		int id=thisJoinPoint.hashCode();
		Object[] paramValues = thisJoinPoint.getArgs();
		paramTypes = new Class[paramValues.length]; 
		int i=0;
		if (paramValues.length>0){
			for (Object temp : paramValues) {
				try {
					paramTypes[i]= temp.getClass();
				} catch (Exception e) {
					e.printStackTrace();
				}
				i++;
			}}
		Signature sig = thisJoinPointStaticPart.getSignature();
		this.target= thisJoinPoint.getTarget();
		try {
			print(sig, paramTypes, paramValues,id);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	Object around(): traceMethods() {
		
		long timestamp = System.currentTimeMillis();
		Object returnValue = proceed();
		if (returnValue!=null ){
			try {
				fileWriter2.write(timestamp+","+thisJoinPoint.hashCode()+",return,"+returnValue.toString().replace("\n","/").replace(",", "±")+","+System.identityHashCode(target)+",NA,NA,NA,NA,NA,NA,NA\n");
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		else 
		{
			try {
				fileWriter2.write(timestamp+","+thisJoinPoint.hashCode()+",return,NA,"+System.identityHashCode(target)+",NA,NA,NA,NA,NA,NA\n");
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return returnValue;
	}
	 after(): traceMethods() {
		_callDepth--;
	}
	private void print(Signature sig, Class[] paramsType, Object[] paramValues, int id) {

		long timestamp = System.currentTimeMillis();
		if (sig instanceof MethodSignature) {
			Method method = ((MethodSignature)sig).getMethod();
			returnType = method.getReturnType().toString();
		}
		traceBefore = "";
		String methode = sig.getName();

		if (target!=null)
		{traceBefore = traceBefore +_callDepth;}
		else{traceBefore = traceBefore  + ",NA,"+id+","+_callDepth; 
		}
		if (paramsType.length == 0) {
			traceBefore = traceBefore +",0,NA,";
		} else {
			traceBefore = traceBefore +","+paramsType.length+",";
			for (int i = 0; i < paramsType.length; i++) {
				try {
					traceBefore = traceBefore+paramsType[i].getName().toString().replace("\n","/").replace(",", "±");
				if (i<paramsType.length-1)
					traceBefore = traceBefore+"//" ;
				else 
					traceBefore = traceBefore+"," ;
				} catch (Exception e) {	
					System.out.println("128");
					traceBefore = traceBefore + ",0,NA,";
				}
			}
		}
		try {
		if (paramValues.length == 0 ) {
			traceBefore = traceBefore + "NA";
		} else {
			for (int i = 0; i < paramValues.length; i++) {
				//traceBefore = traceBefore+ paramValues[i].toString().replace("\n","/").replace(",", "±");
				traceBefore = traceBefore+ paramValues[i].toString();
				if (i<paramsType.length-1)
					traceBefore = traceBefore+"//" ;
			}
		}
	//	fileWriter2.write(timestamp+","+id+",call,"+
		//target.toString().replace("\n","/").replace(",", "±")+","+System.identityHashCode(target)+","+returnType+","+ sig.getDeclaringType().getName() + "." + methode+"," +traceBefore+"\n");
			
		fileWriter2.write(timestamp+","+id+",call,"+
				target.toString()+","+System.identityHashCode(target)+","+returnType+","+ sig.getDeclaringType().getName() + "." + methode+"," +traceBefore+"\n");
				
		fileWriter2.flush();			
		} catch (Exception e) {
		}
	}
}
