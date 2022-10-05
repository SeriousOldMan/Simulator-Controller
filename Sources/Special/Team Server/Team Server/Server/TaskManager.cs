using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class TaskManager : ManagerBase
    {
        public TaskManager(ObjectManager objectManager, Token token) : base(objectManager, token)
        {
        }

        public TaskManager(ObjectManager objectManager, Guid token) : base(objectManager, token)
        {
        }

        public TaskManager(ObjectManager objectManager, string token) : base(objectManager, token)
        {
        }

        #region Task
        #region Validation
        public override Token ValidateToken(Token token)
        {
            return TeamServer.TokenIssuer.ElevateToken(base.ValidateToken(token));
        }

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
        public Model.Task.Task CreateTask(Model.Task.Task.Type which,
                                          Model.Task.Task.Operation what,
                                          Model.Task.Task.Frequency when) {
            DateTime next = DateTime.Now;
            
            if (when == Model.Task.Task.Frequency.Monthly)
                next = new DateTime(next.AddMonths(1).Year, next.AddMonths(1).Month, 1);

            Model.Task.Task task = new Model.Task.Task { Which = which, What = what, When = when, Next = next };

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
        private void CleanupTokens(Model.Task.Task task) {
            if (task.What == Model.Task.Task.Operation.Delete)
                TeamServer.TokenIssuer.CleanupTokensAsync();
            else
                throw new Exception("Unsupported task operation detected...");
        }

        private void CleanupSessions(Model.Task.Task task) {
            SessionManager sessionManager = new SessionManager(ObjectManager, TeamServer.TokenIssuer.InternalToken);

            if (task.What == Model.Task.Task.Operation.Delete)
                sessionManager.DeleteSessionsAsync();
            else if (task.What == Model.Task.Task.Operation.Cleanup)
                sessionManager.CleanupSessionsAsync();
            else if (task.What == Model.Task.Task.Operation.Reset)
                sessionManager.ResetSessionsAsync();
            else
                throw new Exception("Unsupported task operation detected...");

        }

        private void CleanupAccounts(Model.Task.Task task) {
            if (task.What == Model.Task.Task.Operation.Renew)
                new AccountManager(ObjectManager, TeamServer.TokenIssuer.InternalToken).RenewAccountsAsync();
            else if (task.What == Model.Task.Task.Operation.Delete)
                new AccountManager(ObjectManager, TeamServer.TokenIssuer.InternalToken).DeleteAccountsAsync();
            else
                throw new Exception("Unsupported task operation detected...");
        }

        private void RunTask(Model.Task.Task task) {
            if (task.Which == Model.Task.Task.Type.Token)
                CleanupTokens(task);
            else if (task.Which == Model.Task.Task.Type.Session)
                CleanupSessions(task);
            else if (task.Which == Model.Task.Task.Type.Account)
                CleanupAccounts(task);
        }

        private void ScheduleTask(Model.Task.Task task) {
            switch (task.When) {
                case Model.Task.Task.Frequency.Daily:
                    task.Next = DateTime.Now + TimeSpan.FromDays(1);

                    break;
                case Model.Task.Task.Frequency.Weekly:
                    task.Next = DateTime.Now + TimeSpan.FromDays(7);

                    break;
                case Model.Task.Task.Frequency.Monthly:
                    DateTime now = DateTime.Now;

                    task.Next = new DateTime(now.AddMonths(1).Year, now.AddMonths(1).Month, 1);

                    break;
            }

            task.Save();
        }

        public Task RunBackgroundTasksAsync() {
            return Task.Run(RunBackgroundTasks);
        }

        private async void RunBackgroundTasks() {
            while (true) {
                foreach (Model.Task.Task task in GetAllTasks())
                    if ((task.Active) && (task.Next <= DateTime.Now)) {
                        RunTask(task);

                        ScheduleTask(task);
                    }

                TeamServer.TokenIssuer.CleanupConnectionsAsync();

                await Task.Delay(60 * 60 * 1000);
            }
        }
        #endregion
        #endregion
    }
}
