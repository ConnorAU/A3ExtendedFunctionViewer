using RGiesecke.DllExport;
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace A3ExtendedFunctionViewer
{
	public class DllEntry
	{
		private static int taskID = 0;
		internal static string[] sqfCommands;

		private static readonly string AssemblyPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
		private static readonly string LogsFilePath = Path.Combine(AssemblyPath, $"extension.log");

		#region Misc RVExtension Requirements
		public static ExtensionCallback callback;
		public delegate int ExtensionCallback([MarshalAs(UnmanagedType.LPStr)] string name, [MarshalAs(UnmanagedType.LPStr)] string function, [MarshalAs(UnmanagedType.LPStr)] string data);

#if IS_x64
		[DllExport("RVExtensionRegisterCallback", CallingConvention = CallingConvention.Winapi)]
#else
		[DllExport("_RVExtensionRegisterCallback@4", CallingConvention = CallingConvention.Winapi)]
#endif
		public static void RVExtensionRegisterCallback([MarshalAs(UnmanagedType.FunctionPtr)] ExtensionCallback func)
		{
			callback = func;
		}


#if IS_x64
		[DllExport("RVExtensionVersion", CallingConvention = CallingConvention.Winapi)]
#else
        [DllExport("_RVExtensionVersion@8", CallingConvention = CallingConvention.Winapi)]
#endif
		public static void RvExtensionVersion(StringBuilder output, int outputSize)
		{
			outputSize--;
			output.Append("1.0.0");
		}

#if IS_x64
		[DllExport("RVExtension", CallingConvention = CallingConvention.Winapi)]
#else
        [DllExport("_RVExtension@12", CallingConvention = CallingConvention.Winapi)]
#endif
		public static void RvExtension(StringBuilder output, int outputSize,
			[MarshalAs(UnmanagedType.LPStr)] string function)
		{
			outputSize--;
			output.Append(function);
		}

#if IS_x64
		[DllExport("RVExtensionArgs", CallingConvention = CallingConvention.Winapi)]
#else
        [DllExport("_RVExtensionArgs@20", CallingConvention = CallingConvention.Winapi)]
#endif
		#endregion

		public static int RvExtensionArgs(StringBuilder output, int outputSize,
			[MarshalAs(UnmanagedType.LPStr)] string function,
			[MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPStr, SizeParamIndex = 4)] string[] args, int argCount)
		{
			outputSize--;
			int returnCode = -1;
			try
			{
				switch (function)
				{
					case "init":
						if (File.Exists(LogsFilePath) && (DateTime.Now - File.GetLastWriteTime(LogsFilePath)).TotalDays >= 7)
							File.Delete(LogsFilePath);

						sqfCommands = args[0].TrimStart('[').TrimEnd(']').Split(',').Select(s => s.Trim('"')).ToArray();

						returnCode = 0;
						break;

					case "countlines":
					case "highlight":
						taskID++;
						new SyntaxHighlight().Execute(taskID, function, args);
						returnCode = taskID;
						break;
				}
			}
			catch (Exception e)
			{
				Log(e);
				returnCode = -2;
			};
			return returnCode;
		}

		internal static void Log(string s) => File.AppendAllText(LogsFilePath, $"{DateTime.Now} - {s}\n");
		private static void Log(Exception e) => Log($"{e}");
	}
}
