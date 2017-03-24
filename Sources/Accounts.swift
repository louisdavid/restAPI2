class Accounts {
    private var accountsList:[Account] = []
    
    init(account:Account){
        self.accountsList.append(account)
    }
    init(account:[Account]){
        self.accountsList = account
    }
    init(){
        
    }
    
    func addAccount(username:String, email:String, password: String){
        self.accountsList.append(Account(username: username, email: email, password: password))
    }

    
    //returns the content of accountsList as a dictionary
    var dictionary:[String:[[String:String]]] {
        var dict = ["Accounts":[[String:String]]()]
        for acc in self.accountsList {
            dict["Accounts"]?.append(["username":acc.username, "email":acc.email, "password":acc.password])
        }
        return dict
    }
    
    //returns the content of accountList for specific username
    func username(username:String) -> Dictionary<String,Any> {
        var dict = ["Result":[[String:String]]()]
        var b:Bool = true //default to say username not found
        
        for acc in self.accountsList {
            if(acc.username == username) {
                b = false // to say we found a username
                dict["Result"]?.append(["username":acc.username, "email":acc.email, "password":acc.password])
                break
            }
        }
        if(b){ //if no username found
            return (["Result":"Invalid Username, no accounts found"])
        }
        return dict
    }
    
    //return true or false if both password and username are valid
    func loginValid(username:String, password:String) -> Dictionary<String,Any>{
        for acc in self.accountsList {
            if(acc.username == username) {
                if(acc.password == password){
                    return (["Result":"true"])
                }else {
                    return (["Result":"false"])
                }
            }
        }
        return (["Result":"false"])
    }
    
}
