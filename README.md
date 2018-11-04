# hometask

## Introduction

This app is for sharing the task list within a family.

### 1. User log in
Each family can log in using one email address. User can register an email address, or using google authentication

### 2. Tasks List
The main screen is a tableview having all the existing tasks listed.

Only the task title and due date will be displayed in the table view.

####  1. Configuration
In the configuration page, user can pick up / create new name with the family. It would be useful when the user wants to filter the tasks 
list to show the tasks assigned to him/herself only.

Also, here is the place to create / edit the family member. When the 'New Member' is picked, the input textbox will be cleared so that the new
member's name can be created. When an existing name is picked, the user can also modify it in case he / she wants to change the name for
any reason.

Any change will take effect when user click 'Back' to leave this page.

User can log out current family from the Configuration screen.

#### 2. Add New Task
Click the '+' button to add new task (refer to the Task Detail screen)

#### 3. Edit Existing Task
Click the table cell to edit the existing task (refer to the Task Detail screen)

#### 4. Filter /sort the Tasks
There are three buttons at the tab bar below the task list:
* Filtered by tasks completion
* Flitered by task's assignee
* Sorted by due date

### 3. Task Detail
The Task Detail screen can be accessed via adding new task or editting existing task.

A task can have a title, a detail description, an assignee, and a due date. Also user can attach a picture for better presentation.

The task will be created / updated as soon as user press 'Back' to leave this screen.

User can mark a task as completed / incompleted. If a task has been marked as 'Completed', it will be hidden in the Table View unless 'Show Completed Task' option is seleced (in which case, the completed task will have the strike-through displayed.

If user wants to erase the task (not just mark as completed), then click the 'Delete' at the Task Detail screen.

### 4. Network Communication and Local Database
The family and task data are saved in Firebase Realtime Database. Offline buffer has been enabled so any change during offline will be saved locally until the internet connection is restored.

The task photo is stored both in Firebase Storage and Core Data. If the app is offline, the photo will be saved in Core Data only, but the photo will be uploaded to Firebase when that particular Task Detail page has been accessed when internet is available. 

## Installation

sudo gem install cocoapods (if cocoapods has not been installed)
git clone https://github.com/haowu74/hometask.git
cd hometask
pod install
Use Xcode to open HomeTask.xcworkspace (not HomeTask.xcodeproj)



