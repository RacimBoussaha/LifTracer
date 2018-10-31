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
 ArrayList < ArrayList < String >> traceArray = new ArrayList < ArrayList < String >> ();
 ArrayList < String > contentArray;
 ArrayList < String > argsArray;
 ArrayList < String > argsValues;
 Object target;
 String traceBefore = "";
 FileWriter fileWriter;
 File file2;
 FileWriter fileWriter2;
 Class[] paramTypes;
 int i = 0;

 public LogAspect() {

  try {
   file2 = new File("Trace1.csv");
   fileWriter2 = new FileWriter(file2);
   fileWriter2.write("");
   fileWriter2.flush();
   fileWriter2.write("Event timestamp,Event ID,Event type,Calling object,Calling object identity hashcode,Method return type,Method name,Method call depth,Method parameters number,Parameters types,Parameters values\n");
   fileWriter2.flush();
  } catch (IOException e) {
   e.printStackTrace();
  }
 }

 pointcut traceMethods(): !within(LogAspect);


 before(): traceMethods() {

  _callDepth++;

  int id = thisJoinPoint.hashCode();
  Object[] paramValues = thisJoinPoint.getArgs();
  paramTypes = new Class[paramValues.length];
  int i = 0;
  if (paramValues.length > 0) {
   for (Object temp: paramValues) {
    try {
     paramTypes[i] = temp.getClass();
    } catch (Exception e) {}
    i++;
   }
  }
  Signature sig = thisJoinPointStaticPart.getSignature();
  this.target = thisJoinPoint.getTarget();
  try {
   print(sig, paramTypes, paramValues, id);
  } catch (Exception e) {
   e.printStackTrace();
  }
 }

 Object around(): traceMethods() {

  long timestamp = System.currentTimeMillis();
  Object returnValue = proceed();
  if (returnValue != null) {
   try {
    fileWriter2.write(timestamp + "," + thisJoinPoint.hashCode() + ",return," + clean(returnValue.toString()) + "," + System.identityHashCode(target) + ",NA,NA,NA,NA,NA,NA\n");
    fileWriter2.flush();
   } catch (IOException e) {
    e.printStackTrace();
   }
  } else {
   try {
    fileWriter2.write(timestamp + "," + thisJoinPoint.hashCode() + ",return,NA," + System.identityHashCode(target) + ",NA,NA,NA,NA,NA,NA\n");
    fileWriter2.flush();
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
   Method method = ((MethodSignature) sig).getMethod();
   returnType = method.getReturnType().toString();
  }
  traceBefore = "";
  String methode = sig.getName();
  String targetObj = "";
  String targetIhc = "";

  if (target != null) {
   targetObj = clean(target.toString());
   targetIhc = clean(Integer.toString(System.identityHashCode(target)));
  } else {
   targetObj = "NA";
   targetIhc = "NA";
  }

  if ((paramsType.length == 0)) {
   traceBefore = traceBefore + ",0,NA,";
  } else {
   traceBefore = traceBefore + "," + paramsType.length + ",";
   for (int i = 0; i < paramsType.length; i++) {
    if (paramsType[i] == null) {
     traceBefore = traceBefore + "NULL";
    } else
     traceBefore = traceBefore + clean(paramsType[i].getName().toString());
    if (i == paramsType.length - 1)
     traceBefore = traceBefore + ",";
    else
     traceBefore = traceBefore + "//";
   }
  }

  if ((paramValues.length == 0)) {
   traceBefore = traceBefore + "NA";
  } else {
   if (paramValues[i] == null) {
    traceBefore = traceBefore + "NULL";
   }
   for (int i = 0; i < paramValues.length; i++) {
    if (paramValues[i] == null) {} else
     traceBefore = traceBefore + clean(paramValues[i].toString());
    if (i < paramsType.length - 1)
     traceBefore = traceBefore + "//";
   }
  }
  try {
   fileWriter2.write(timestamp + "," + id + ",call," +
    targetObj + "," + targetIhc + "," + returnType + "," + sig.getDeclaringType().getName() + "." + methode + "," + _callDepth + traceBefore + "\n");

   fileWriter2.flush();

  } catch (IOException e) {}

 }

 private String clean(String st) {

  String rt = st;
  if (rt.contains("\n")) {
   rt = rt.replace("\n", "/");
  }
  if (rt.contains(",")) {
   rt = rt.replace(",", "(comma)");
  }
  return rt;
 }
}
