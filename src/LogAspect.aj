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
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	pointcut traceMethods(): 

		!within(LogAspect) 
		&& !initialization(* .new(..)) ;


	before(): traceMethods() {
		_callDepth++;
		try {
			fileWriter2.write("");
		} catch (IOException e1) {
			// TODO Auto-generated catch block
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
					// TODO Auto-generated catch block

				}
				i++;

			}}
		Signature sig = thisJoinPointStaticPart.getSignature();
		this.target= thisJoinPoint.getTarget();


		try {
			print(sig, paramTypes, paramValues,id);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}


	}


	//	after()returning(Object r): traceMethods() {
	Object around(): traceMethods() {
		_callDepth--;
		//Object returnValue = r;
		long timestamp = System.currentTimeMillis();
		Object returnValue = proceed();


		if (returnValue!=null ){


			//alist.add("output // "+returnValue.toString()+" // "+thisJoinPoint.hashCode()+"\n");
			//source.setEvents("output // "+returnValue.toString()+" // "+thisJoinPoint.hashCode()+"\n");
			try {
				fileWriter2.write(timestamp+",return,"+returnValue.toString()+",,,,,,"+thisJoinPoint.hashCode()+"\n");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			//String x =  (p.pull()).toString();
			//System.out.println("The event is: " + x);

		}
		else 
		{


			//alist.add("output // "+"NAN // "+thisJoinPoint.hashCode()+"\n");
			try {
				fileWriter2.write(timestamp+",return,"+"NA,,,,,,"+thisJoinPoint.hashCode()+"\n");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			//String x =  (p.pull()).toString();
			//System.out.println("The event is: " + x);


		}
		return returnValue;

	}

	private void print(Signature sig, Class[] paramsType, Object[] paramValues, int id) {

		long timestamp = System.currentTimeMillis();

		if (sig instanceof MethodSignature) {
			Method method = ((MethodSignature)sig).getMethod();
			returnType = method.getReturnType().toString();

		}
		traceBefore = "";
		String methode = sig.getName();
		traceBefore = traceBefore +returnType+"," + sig.getDeclaringType().getName() + "." + methode+"," ;
		if (paramsType.length == 0) {
			traceBefore = traceBefore + "NA";
		} else {

			for (int i = 0; i < paramsType.length; i++) {
				
				try {
					traceBefore = traceBefore + "/" + paramsType[i].getName() ;
				} catch (Exception e) {
					// TODO Auto-generated catch block
					traceBefore = traceBefore + "NA";
				}

			}

		}
		traceBefore = traceBefore + ",";

		String paramLen ="";
		if (paramValues.length == 0) {

			traceBefore = traceBefore + "NA";
		} else {
			for (int i = 0; i < paramValues.length; i++) {

				/*if(methode.equals("write") && i==0){

					paramLen = ","+paramValues[0];

				}

				if(methode.equals("readline") && i==0){

					paramLen = ""+paramValues[0];

				}*/
				traceBefore = traceBefore + "/"+ paramValues[i]  ;


			}
		}
		

		traceBefore = traceBefore + "," +_callDepth;
		if (target!=null)
		{traceBefore = traceBefore + ","+ System.identityHashCode(target);}
		else{traceBefore = traceBefore  + ",NA"; 
		}

		try {



			fileWriter2.write(timestamp+",call,"+traceBefore+","+id+"\n");

			fileWriter2.flush();
			
		} catch (IOException e) {

			e.printStackTrace();
		}

	

	}








}