using System.Collections.Generic;
using System.Linq;
using System;
using System.Collections.ObjectModel;
using System.Reflection;

namespace TeamServer.Controllers {
    public static class ControllerUtils {
        public static TValue GetValueOrDefault<TKey, TValue>(this IDictionary<TKey, TValue> dictionary, TKey key, TValue defaultValue) {
            return dictionary.TryGetValue(key, out TValue value) ? value : defaultValue;
        }

        public static TValue GetValueOrDefault<TKey, TValue>(this IDictionary<TKey, TValue> dictionary, TKey key, Func<TValue> defaultValueProvider) {
            return dictionary.TryGetValue(key, out TValue value) ? value : defaultValueProvider();
        }

        public static Dictionary<string, string> ParseKeyValues(string text) {
            var keyValues = text.Replace("\r", "").Split('\n');
                
            return keyValues.Select(value => value.Split('=')).ToDictionary(pair => pair[0].Trim(), pair => pair[1].Trim());
        }

        public static string SerializeObject(Object obj, List<string> properties, string prefix = "") {
            Type type = obj.GetType();
            string serialized = "";

            foreach (string property in properties) {
                if (serialized.Length > 0)
                    serialized += '\n';

                var value = type.GetProperty(property).GetValue(obj);

                serialized += prefix + property + "=" + ((value == null) ? "" : value.ToString());
            }

            return serialized;
        }

        public static void DeserializeObject(Object obj, Dictionary<string, string> properties) {
            Type type = obj.GetType();

            foreach (var entry in properties) {
                PropertyInfo propertyInfo = type.GetProperty(entry.Key);

                propertyInfo.SetValue(obj, Convert.ChangeType(entry.Value, propertyInfo.PropertyType));
            }
        }
        public static void DeserializeObject(Object obj, string keyValues) {
            DeserializeObject(obj, ParseKeyValues(keyValues));
        }
    }
}
