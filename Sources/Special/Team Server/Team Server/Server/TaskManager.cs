using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class TaskManager : ManagerBase {
        public TaskManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        #region Task
        #region Validation

        public void ValidateTask(Model.Task.Task task) {
            if (task == null)
                throw new Exception("Not a known task...");
        }
        #endregion

        #region Query
        public List<Model.Task.Task> GetAllTasks() {
            return TeamServer.ObjectManager.Connection.QueryAsync<Model.Task.Task>(
                @"
                    Select * From Task_Tasks
                ").Result;
        }

        public Model.Task.Task FindTask(Guid identifier) {
            return ObjectManager.GetTaskAsync(identifier).Result;
        }

        public Model.Task.Task FindTask(string identifier) {
            Task<Model.Task.Task> finder = ObjectManager.GetTaskAsync(identifier);
            Model.Task.Task task;

            try {
                task = FindTask(new Guid(identifier));
            }
            catch {
                task = null;
            }

            return task ?? finder.Result;
        }

        public Model.Task.Task LookupTask(Guid identifier) {
            Model.Task.Task task = FindTask(identifier);

            ValidateTask(task);

            return task;
        }

        public Model.Task.Task LookupTask(string identifier) {
            return FindTask(identifier) ?? LookupTask(new Guid(identifier));
        }
        #endregion

        #region CRUD
        public Model.Task.Task CreateTask(string name, Model.Task.Task.Type what, Model.Task.Task.Period when) {
            Model.Task.Task task = new Model.Task.Task { Name = name, What = what, When = when };

            task.Save();

            return task;
        }

        public void DeleteTask(Model.Task.Task task) {
            ValidateTask(task);

            task.Delete();
        }

        public void DeleteTask(Guid identifier) {
            DeleteTask(LookupTask(identifier));
        }

        public void DeleteTask(string identifier) {
            DeleteTask(LookupTask(identifier));
        }
        #endregion

        #region Operations
        private void CleanupTokens() {
            TeamServer.TokenIssuer.CleanupTokensAsync();
        }

        private void RenewContingents() {
            new AccountManager(ObjectManager, TeamServer.TokenIssuer.AdminToken).RenewAccountsAsync();
        }

        private void RunTask(Model.Task.Task task) {
            if (task.What == Model.Task.Task.Type.Cleanup)
                CleanupTokens();
            else if (task.What == Model.Task.Task.Type.Renewal)
                RenewContingents();
        }

        private void ScheduleTask(Model.Task.Task task) {
            switch (task.When) {
                case Model.Task.Task.Period.Daily:
                    task.Next = DateTime.Now + TimeSpan.FromDays(1);

                    break;
                case Model.Task.Task.Period.Weekly:
                    task.Next = DateTime.Now + TimeSpan.FromDays(7);

                    break;
                case Model.Task.Task.Period.Monthly:
                    DateTime now = DateTime.Now;

                    task.Next = new DateTime(now.AddMonths(1).Year, now.AddMonths(1).Month, 1);

                    break;
            }
        }

        public Task RunBackgroundTasksAsync() {
            return Task.Run(RunBackgroundTasks);
        }

        private void RunBackgroundTasks() {
            while (true) {
                foreach (Model.Task.Task task in GetAllTasks())
                    if ((task.Active) && (task.Next < DateTime.Now)) {
                        RunTask(task);

                        ScheduleTask(task);
                    }

                Task.Delay(60 * 60 * 1000);
            }
        }
        #endregion
        #endregion
    }
}
